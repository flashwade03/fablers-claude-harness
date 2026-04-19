---
name: agent-teams
description: "Use when the user asks to run, spawn, or coordinate real agent teams — e.g. '에이전트 팀 만들어줘', '팀으로 병렬 작업해줘', 'agent-teams로 토론해줘', 'spawn a team', 'debate with agent teams', 'coordinate multiple agents'. Orchestrates Claude Code agent teams using TeamCreate, TaskCreate, Agent(team_name), and SendMessage — never simulating teams with single-agent persona role-play. Do NOT trigger for the /forge-team command (damascus has its own orchestrator) or for simple 2-agent parallel work that a direct Agent multi-call handles."
---

# Agent-Teams Orchestration

## Purpose

Correctly execute Claude Code agent-teams for parallel work: debates, reviews, research, and implementation. This skill ensures the real TeamCreate + SendMessage infrastructure is used, not single-agent simulation.

## Critical Anti-Pattern

**NEVER simulate agent-teams by spawning a single Agent that role-plays multiple personas.** This is the most common mistake:

```
# WRONG — single agent pretending to be 4 people
Agent(prompt="You are 4 experts: A (purist), B (pragmatist), C (engineer), D (philosopher). Debate about X.")
```

This produces a monologue, not a real debate. Each "persona" shares the same context, same biases, same blind spots.

```
# CORRECT — real agent-teams with independent context windows
TeamCreate("my-debate") → TaskCreate(...) → Agent(team_name="my-debate", name="purist") × N
```

Real teammates have independent context windows, can challenge each other's findings, and communicate via SendMessage.

## When NOT to Use

Skip the full team infrastructure when any of these hold — the overhead isn't worth it:

- **≤ 2 agents doing independent parallel work** — just call `Agent(...)` twice in one message. No team needed.
- **No cross-agent communication required** — if agents never need to challenge or respond to each other, parallel `Agent` calls are simpler.
- **The `/forge-team` command is being invoked** — that path is handled by `damascus`'s `forge-team` skill. Do not double-orchestrate.
- **One-shot question needing a single expert answer** — use a single `Agent` call with the appropriate `subagent_type`.

Rule of thumb: reach for agent-teams when you need **≥ 3 agents** AND **cross-agent interaction** (debate, peer review, coordinated implementation).

## Prerequisite

Agent-teams requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `.claude/settings.json`. If `TeamCreate` fails with an "experimental" error, tell the user to enable it.

## Scope Boundary

This skill covers **general-purpose** agent-team orchestration. It does NOT cover:
- `/forge-team` sessions → see `damascus/skills/forge-team`
- Debugging stuck `damascus-forge` sessions → see `damascus/skills/forge-team-debugger`

If the user's task is document forging via damascus, defer to those skills.

## Token Cost Awareness

Every teammate is a separate Claude instance with its own context window. Be deliberate:

- **N teammates ≈ N× the token cost** of a single agent — a 5-agent team burns ~5× the tokens of one Agent call.
- Each teammate **does not inherit the lead's conversation history** — context must be passed explicitly in the spawn prompt, which costs tokens.
- For long debates (many SendMessage rounds), costs compound quickly. Set an implicit or explicit round budget.

Before spawning, briefly tell the user the team size and why that size fits the task.

## Workflow

### Phase 1: Setup

Create the team, then create initial tasks. Additional tasks can be added dynamically as work progresses.

### Phase 2: Spawn Teammates

Spawn teammates in parallel (multiple `Agent` calls in one message). Teammates do NOT inherit the lead's conversation history — include necessary project context in each spawn prompt.

### Phase 3: Coordinate

- **Messages arrive automatically** — do NOT poll or sleep.
- **Idle is normal** — teammates go idle between turns; this is expected, not an error.
- **Assign tasks** via `TaskUpdate` with `owner` parameter.
- **Redirect** teammates via `SendMessage` if their approach isn't working.
- **Wait for ALL results** — do not move to Synthesize until every teammate has sent final results. Do not implement work yourself while teammates are working.

### Phase 4: Synthesize

After all teammates complete their tasks:
1. Review all teammate findings/deliverables.
2. Synthesize into a coherent result.
3. Present to the user with attribution to each teammate's contribution.

### Phase 5: Cleanup

Teammates naturally terminate after completing their tasks and sending results. No explicit shutdown is needed in most cases. If a teammate appears stuck, send a message via `SendMessage` to redirect or wrap up. For long-running teams, call `TeamDelete(team_name)` once work is confirmed done.

## Cross-Challenge Pattern (Debates Only)

A "debate" where agents only report to the lead is **parallel analysis**, not a debate. For real debate, the spawn prompt must require each agent to read and challenge peers before final positions settle.

Include a block like this in each debater's spawn prompt:

```
You are one of N debaters on [topic]. Your initial position: [X].

Round 1: Send your initial argument to every other debater via SendMessage.
Round 2: You will receive their arguments. Identify the strongest counter
         to your position and respond to its author directly — do not just
         reassert your view. Quote the specific claim you are challenging.
Round 3: Send your final refined position to the Lead ("team-lead").
         If your view changed, say what changed it.

Disagreement is the goal. If by round 2 you agree with everyone, you are
not engaging deeply enough — find the weakest assumption in the consensus.
```

Without this kind of structure, agents default to agreeable summaries.

## Worked Examples

### Example A — 3-agent debate ("should we adopt X?")

```
# 1. Create team
TeamCreate(team_name: "adopt-x-debate",
           description: "Debate whether to adopt X in our codebase")

# 2. Seed tasks
TaskCreate(subject: "Argue FOR adopting X")
TaskCreate(subject: "Argue AGAINST adopting X")
TaskCreate(subject: "Argue for a hybrid / staged adoption")

# 3. Spawn all 3 in one message (parallel Agent calls)
Agent(team_name: "adopt-x-debate", name: "advocate",
      subagent_type: "general-purpose",
      prompt: "[project context] ... You advocate FOR X. [cross-challenge block]")
Agent(team_name: "adopt-x-debate", name: "skeptic",
      subagent_type: "general-purpose",
      prompt: "[project context] ... You argue AGAINST X. [cross-challenge block]")
Agent(team_name: "adopt-x-debate", name: "hybrid",
      subagent_type: "general-purpose",
      prompt: "[project context] ... You propose a staged adoption. [cross-challenge block]")

# 4. Wait for all three final positions → Synthesize → Report with attribution
```

### Example B — 2-module implementation team

Even 2 teammates can be worth a team if they must coordinate file writes without stepping on each other.

```
TeamCreate(team_name: "refactor-auth",
           description: "Split auth module into api/ and core/")

TaskCreate(subject: "Own src/auth/api/* — extract HTTP layer")
TaskCreate(subject: "Own src/auth/core/* — extract domain logic")
TaskCreate(subject: "Update imports across the rest of the codebase",
           description: "Runs AFTER both owners finish")  # set blockedBy later

Agent(team_name: "refactor-auth", name: "api-owner",
      subagent_type: "general-purpose",
      prompt: "You own src/auth/api/*. Do NOT write to src/auth/core/*.
               Coordinate with 'core-owner' via SendMessage for shared types. ...")
Agent(team_name: "refactor-auth", name: "core-owner",
      subagent_type: "general-purpose",
      prompt: "You own src/auth/core/*. Do NOT write to src/auth/api/*. ...")

# After both report done → spawn a third teammate for the import sweep,
# or handle it yourself since no coordination remains.
```

Key constraint: **never assign the same file to two teammates** — last-write-wins will silently destroy work.

## Important Behaviors

- Each teammate is a separate Claude instance with its own context window and token budget.
- Idle notifications are normal — teammates go idle between turns, not an error or completion signal.
- Teammates can message each other directly via `SendMessage`, not just the team lead.
- For implementation teams, avoid assigning two teammates to the same file (causes overwrites).

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Not giving teammates enough context | Teammates don't inherit conversation history — provide background directly in the spawn prompt |
| Treating idle as "done" or "error" | Idle = waiting for input, completely normal |
| Lead doing work instead of delegating | Wait for teammates to finish before synthesizing or implementing |
| Debate request but no cross-agent interaction before synthesizing | Debates require agents to challenge each other via SendMessage — see Cross-Challenge Pattern |
| Spawning a team for 2 independent tasks | Just call `Agent(...)` twice in parallel — no team needed |
| Same file assigned to two implementation teammates | Split ownership by path or module; last-write-wins destroys work silently |

## Implementation Pattern Notes

For code implementation teams (vs debates/reviews), additionally:

- **Assign file ownership** — each teammate owns specific files/modules. Never assign the same file to two teammates.
- **Use task dependencies** — `TaskUpdate(blockedBy=[taskId])` for phased execution (e.g., interfaces first, then implementations).
- **Teammates write code, not opinions** — goal is committed code, not analysis.
