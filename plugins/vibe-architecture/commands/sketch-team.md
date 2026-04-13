---
name: sketch-team
description: "Design + review bundled into one Agent Teams workflow — parallel designers explore approaches, a planner synthesizes, a scribe writes, two reviewers judge against the 6-axis rubric, loop until approved."
argument-hint: "[-n max] [-o path] <task description>"
---

# Sketch Team

Design a system end-to-end using Agent Teams. Parallel Designers explore distinct approaches to the same task, a Planner cross-pollinates their findings and synthesizes a unified draft, a Scribe writes the design doc, and two Reviewers judge against the 6-axis vibe-coding rubric. Teammates stay alive across rounds — no resume needed. The loop terminates when the design passes review or `max_rounds` is reached.

Lead conducts a dialogue with you first (vibe-design Step 0.5–1.5 — target doc confirmation + user-only decisions) before the team spawns. The team handles the AI-judgment-OK decisions, drafting, review, and revision.

## Workflow

1. **Lead dialogue** — confirms target doc + locks user-only decisions (UX, scope, priorities) via vibe-design Step 0.5–1.5
2. **Designers** (1–3, Lead-decided) → explore distinct approaches, report to Planner (preliminary → cross-pollinated → refined)
3. **Planner** → synthesize refined approaches into unified draft text, return to Lead
4. **Scribe** → write design doc to output path
5. **Reviewers** (Content + Structure) → judge against the 6-axis rubric independently, send verdicts to Lead
6. **Lead** → consolidate; any FAIL → NEEDS_REVISION else APPROVED
7. **Scribe** → write `.review.md` with round history
8. **Loop** → If NEEDS_REVISION and rounds remain, Planner revises with consolidated feedback. Max rounds → escalate to user.

## Usage

```
/sketch-team [-n max] [-o output_path] [task description]
```

- `-n`: Maximum rounds (default: 3)
- `-o`: Output file path (optional — if omitted, resolved from project conventions or asked during Lead dialogue)

Examples:
```
/sketch-team design a job queue that handles retries and priorities
/sketch-team -n 5 architect multi-tenant data isolation
/sketch-team -o docs/features/notifications.md design the notification system
```

---

**Instructions:** Follow the `sketch-team-orchestrator` skill to execute this workflow.

**Parse arguments:**
- Extract `-n [number]` if present → `max_rounds` (default: 3)
- Extract `-o [path]` if present → `output_path` (default: none)
- Remaining text → `task_description`

**User input:** $ARGUMENTS
