#!/usr/bin/env python3
"""Skill description optimizer using `claude -p` (no Anthropic SDK required).

Orchestrates: baseline eval -> propose improved description via claude -p ->
re-evaluate -> iterate. Selects the best description by test-set score to
avoid overfitting.
"""
import argparse, json, os, random, re, subprocess, sys, tempfile
from pathlib import Path

SKILL_CREATOR = Path.home() / ".claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator"


def parse_skill_md(skill_path: Path):
    content = (skill_path / "SKILL.md").read_text()
    m = re.match(r"^---\n(.*?)\n---\n(.*)", content, re.DOTALL)
    if not m:
        raise ValueError("No YAML frontmatter found")
    fm, body = m.group(1), m.group(2)
    name = re.search(r"^name:\s*(.+)$", fm, re.MULTILINE).group(1).strip()
    desc = re.search(r"^description:\s*(.+)$", fm, re.MULTILINE).group(1).strip().strip('"')
    return name, desc, body


def run_eval(skill_path: Path, eval_set: Path, model: str, description: str | None = None) -> dict:
    cmd = [sys.executable, "-m", "scripts.run_eval",
           "--eval-set", str(eval_set.resolve()),
           "--skill-path", str(skill_path.resolve()),
           "--model", model,
           "--num-workers", "1"]
    if description:
        cmd.extend(["--description", description])
    result = subprocess.run(cmd, cwd=SKILL_CREATOR, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"run_eval failed:\n{result.stderr}")
    # run_eval.py prints JSON after the progress stderr; capture from stdout
    stdout = result.stdout
    idx = stdout.find("{")
    return json.loads(stdout[idx:])


def build_prompt(skill_name, skill_body, current_desc, eval_results, history):
    failed = [r for r in eval_results["results"] if r["should_trigger"] and not r["pass"]]
    false_pos = [r for r in eval_results["results"] if not r["should_trigger"] and not r["pass"]]
    s = f"""You are optimizing the description for a Claude Code skill called "{skill_name}".

The description appears in Claude's available_skills list. Claude decides whether to invoke the skill based on the name+description alone. Your goal: trigger for relevant queries, avoid triggering for irrelevant ones.

Current description:
<current_description>
{current_desc}
</current_description>

Scores: {eval_results['summary']['passed']}/{eval_results['summary']['total']}

"""
    if failed:
        s += "FAILED TO TRIGGER (should have):\n"
        for r in failed:
            s += f'  - "{r["query"]}" ({r["triggers"]}/{r["runs"]})\n'
        s += "\n"
    if false_pos:
        s += "FALSE TRIGGERS (should not have):\n"
        for r in false_pos:
            s += f'  - "{r["query"]}" ({r["triggers"]}/{r["runs"]})\n'
        s += "\n"
    if history:
        s += "PREVIOUS ATTEMPTS (do NOT repeat — try structurally different approaches):\n\n"
        for h in history:
            s += f'<attempt score={h["passed"]}/{h["total"]}>\n{h["description"]}\n</attempt>\n\n'
    s += f"""Skill body for context:
<skill_body>
{skill_body[:3000]}
</skill_body>

Write a new description that is more likely to trigger correctly. Generalize from failures to broader user intents — don't overfit to specific queries. Keep it under 200 words and under 1024 characters.

Tips:
- Imperative: "Use this skill for..." not "this skill does..."
- Focus on user intent, not implementation details
- Be distinctive — compete for Claude's attention
- Try structurally different wording each iteration

Respond with only the new description inside <new_description> tags."""
    return s


def propose_description(prompt: str, model: str) -> str:
    result = subprocess.run(
        ["claude", "-p", "--model", model],
        input=prompt, capture_output=True, text=True, timeout=600
    )
    if result.returncode != 0:
        raise RuntimeError(f"claude -p failed:\n{result.stderr}")
    text = result.stdout
    m = re.search(r"<new_description>(.*?)</new_description>", text, re.DOTALL)
    desc = m.group(1).strip().strip('"') if m else text.strip().strip('"')
    return desc.strip('"').strip("'")


def split_eval_set(eval_set_path: Path, train_ratio: float = 0.6, seed: int = 42):
    items = json.loads(eval_set_path.read_text())
    random.Random(seed).shuffle(items)
    k = int(len(items) * train_ratio)
    train, test = items[:k], items[k:]
    train_path = eval_set_path.parent / f"{eval_set_path.stem}.train.json"
    test_path = eval_set_path.parent / f"{eval_set_path.stem}.test.json"
    train_path.write_text(json.dumps(train, indent=2, ensure_ascii=False))
    test_path.write_text(json.dumps(test, indent=2, ensure_ascii=False))
    return train_path, test_path


def score_summary(r: dict) -> str:
    s = r["summary"]
    pos = [x for x in r["results"] if x["should_trigger"]]
    pos_pass = sum(1 for x in pos if x["pass"])
    return f"{s['passed']}/{s['total']} (recall {pos_pass}/{len(pos)})"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--eval-set", required=True)
    ap.add_argument("--skill-path", required=True)
    ap.add_argument("--model", required=True)
    ap.add_argument("--max-iterations", type=int, default=5)
    ap.add_argument("--workspace", default=None, help="Output directory for artifacts")
    args = ap.parse_args()

    skill_path = Path(args.skill_path)
    eval_set = Path(args.eval_set)
    workspace = Path(args.workspace) if args.workspace else skill_path.parent / "optimize-workspace"
    workspace.mkdir(parents=True, exist_ok=True)

    name, current_desc, body = parse_skill_md(skill_path)
    train_set, test_set = split_eval_set(eval_set)
    print(f"Split: train={len(json.loads(train_set.read_text()))} test={len(json.loads(test_set.read_text()))}")

    # Baseline
    print(f"\n=== Iteration 0 (baseline) ===")
    print(f"Description: {current_desc[:80]}...")
    train_r = run_eval(skill_path, train_set, args.model, current_desc)
    test_r = run_eval(skill_path, test_set, args.model, current_desc)
    print(f"  train: {score_summary(train_r)} | test: {score_summary(test_r)}")

    best = {
        "description": current_desc,
        "train_score": train_r["summary"]["passed"],
        "train_total": train_r["summary"]["total"],
        "test_score": test_r["summary"]["passed"],
        "test_total": test_r["summary"]["total"],
    }
    history = [{
        "description": current_desc,
        "passed": train_r["summary"]["passed"],
        "total": train_r["summary"]["total"],
    }]

    for i in range(1, args.max_iterations + 1):
        print(f"\n=== Iteration {i} ===")
        prompt = build_prompt(name, body, best["description"], train_r, history)
        (workspace / f"prompt_{i}.txt").write_text(prompt)
        new_desc = propose_description(prompt, args.model)
        (workspace / f"description_{i}.txt").write_text(new_desc)
        print(f"Proposed: {new_desc[:120]}...")

        train_r = run_eval(skill_path, train_set, args.model, new_desc)
        test_r = run_eval(skill_path, test_set, args.model, new_desc)
        print(f"  train: {score_summary(train_r)} | test: {score_summary(test_r)}")

        history.append({
            "description": new_desc,
            "passed": train_r["summary"]["passed"],
            "total": train_r["summary"]["total"],
        })

        if test_r["summary"]["passed"] > best["test_score"]:
            best = {
                "description": new_desc,
                "train_score": train_r["summary"]["passed"],
                "train_total": train_r["summary"]["total"],
                "test_score": test_r["summary"]["passed"],
                "test_total": test_r["summary"]["total"],
            }
            print("  ** new best **")

    result = {
        "skill": name,
        "best_description": best["description"],
        "best_train": f"{best['train_score']}/{best['train_total']}",
        "best_test": f"{best['test_score']}/{best['test_total']}",
        "history": history,
    }
    (workspace / "result.json").write_text(json.dumps(result, indent=2, ensure_ascii=False))
    print(f"\n=== Done ===\nBest: train={result['best_train']} test={result['best_test']}")
    print(f"Saved to: {workspace}/result.json")


if __name__ == "__main__":
    main()
