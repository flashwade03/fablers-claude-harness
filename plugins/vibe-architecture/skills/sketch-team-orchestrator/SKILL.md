---
name: sketch-team-orchestrator
description: "Internal orchestration logic for the /sketch-team command. Do not trigger on general questions about agent teams, design workflows, or parallel exploration — only when the /sketch-team command is explicitly invoked."
---

# sketch-team-orchestrator

You are the **Lead** of a sketch-team Agent Team. You orchestrate the dialogue phase and rounds of designing, writing, and reviewing — but you do NOT write documents or judge design content yourself.

## Configuration

Parse from user input:
- `-n [number]` → `max_rounds` (default: 3)
- `-o [path]` → `output_path` (default: none, resolved during dialogue)
- Remaining text → `task_description`

## Phase 0 — Lead Dialogue (before team spawn)

Before creating the team, Lead conducts vibe-design Step 0.5–1.5 with the user. Read `${CLAUDE_PLUGIN_ROOT}/skills/vibe-design/SKILL.md` and execute **only** steps 0.5 (target doc confirmation), 1 (Scope Check), and 1.5 (idea exploration dialogue). Skip steps 2–7 — the team handles those phases.

### Scope Check Exit

If Step 1 Scope Check concludes "설계 불필요 (바로 구현)", tell the user and exit — do NOT spawn a team for trivial changes.

### Lock the Decision Sheet

At the end of dialogue, produce a structured decision sheet:

```
## Confirmed Decisions
- [Decision]: [what] — because [why from dialogue]
- [Decision]: [what] — because [why from dialogue]
...

## Open Decisions (Planner / Designers may decide autonomously)
- [Technical choice still open]
- [Library / pattern selection]
- [Internal structure]
...

## Target Document
Path: [resolved from -o flag, project convention, or user confirmation]
Action: [create new | update existing]
```

Keep this sheet — you will embed it in Planner's initial message.

## Phase 1 — Team Setup (one-time)

### 1. Resolve Plugin Root

```
Bash(command: "echo $CLAUDE_PLUGIN_ROOT")
```

If empty, derive from this skill file's location — strip `/skills/sketch-team-orchestrator/SKILL.md` from the path. Store as `PLUGIN_ROOT`.

### 2. Decide Designer Count and Approach Labels

From the Confirmed + Open Decisions sheet, identify the **contested trade-off space**:
- If there are 2–3 genuinely different ways to approach the core structural problem (e.g., WebSocket vs SSE vs polling; monolith-first vs service-boundary-first; eager-load vs lazy-load) → assign one Designer per approach, `designer_count = 2` or `3`
- If the direction is essentially settled and only details remain → `designer_count = 1`

Assign each Designer a **distinct approach label** that summarises their directional frame. Examples:
- `approach-conservative` (prefer proven patterns, lowest risk)
- `approach-balanced` (mainstream choice for this domain)
- `approach-minimal` (smallest-viable surface, YAGNI-first)
- `approach-aggressive` (optimised for future scale)
- domain-specific labels when the axis is clearer (e.g., `approach-websocket`, `approach-sse`)

**Cap: never spawn more than 3 Designers.**

### 3. Assign Models

Hardcoded for v0:
- `designer-[N]`: sonnet
- `planner`: sonnet
- `scribe`: haiku
- `reviewer-content`: haiku
- `reviewer-structure`: haiku

### 4. Create Team

```
TeamCreate(
  team_name: "sketch-team",
  description: "Sketching: [TASK_DESCRIPTION]"
)
```

### 5. Spawn Teammates

**MANDATORY**: Before spawning, `Read("references/teammate-prompts.md")`. Use the exact text from each `Spawn prompt:` code block as the `prompt` parameter — do not write prompts from memory.

Spawn all teammates in a single message (parallel Agent calls). Each joins the team via `team_name: "sketch-team"`.

**Designers** (spawn `designer_count` instances, `N = 1..designer_count`):
```
Agent(
  team_name: "sketch-team",
  name: "designer-[N]",
  subagent_type: "Explore",
  model: "sonnet",
  prompt: [EXACT text from ## Designer spawn prompt, with [N] and [APPROACH_LABEL] substituted]
)
```

**Planner** (single instance, `subagent_type: "Explore"`):
```
Agent(
  team_name: "sketch-team",
  name: "planner",
  subagent_type: "Explore",
  model: "sonnet",
  prompt: [EXACT text from ## Planner spawn prompt]
)
```

**Scribe** (`subagent_type: "general-purpose"` — needs Write tool):
```
Agent(
  team_name: "sketch-team",
  name: "scribe",
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: [EXACT text from ## Scribe spawn prompt]
)
```

**Reviewers** (both always spawned — 6 axes split between them):
```
Agent(
  team_name: "sketch-team",
  name: "reviewer-content",
  subagent_type: "Explore",
  model: "haiku",
  prompt: [EXACT text from ## Reviewer — Content spawn prompt]
)

Agent(
  team_name: "sketch-team",
  name: "reviewer-structure",
  subagent_type: "Explore",
  model: "haiku",
  prompt: [EXACT text from ## Reviewer — Structure spawn prompt]
)
```

## Round Execution

For detailed step-by-step procedures and exact SendMessage payloads for each phase, consult **`references/round-flow.md`**.

### Workflow Overview

```
  Phase 0 (once): Lead ──dialogue──▶ User (vibe-design Step 0.5-1.5)
       │  decision sheet locked
       ▼
  Phase 1 (once): Create Team → Spawn all teammates
       │
       ▼
  ┌─── Round N ──────────────────────────────────────────────────┐
  │                                                              │
  │  Lead ──msg──▶ Planner (decisions + designer labels,         │
  │                           or revision feedback if N>1)       │
  │                                                              │
  │  Planner ──msg──▶ Designers (assign approach labels)         │
  │  Designers ──msg──▶ Planner (preliminary approaches)         │
  │  Planner ──msg──▶ Designers (peer summaries + gap-check)     │
  │  Designers ──msg──▶ Planner (refined approaches)             │
  │  Planner ──msg──▶ Lead (unified draft text)                  │
  │                                                              │
  │  Lead ──msg──▶ Scribe (draft + output path, write design)    │
  │  Scribe ──msg──▶ Lead (write confirmed)                      │
  │                                                              │
  │  Lead ──msg──▶ reviewer-content + reviewer-structure         │
  │  Reviewers ──msg──▶ Lead (3-axis verdict each)               │
  │  Lead: consolidate — any FAIL ⇒ NEEDS_REVISION               │
  │                                                              │
  │  Lead ──msg──▶ Scribe (consolidated review → .review.md)     │
  │  Scribe ──msg──▶ Lead (review file confirmed)                │
  │                                                              │
  └──────────────────────────────────────────────────────────────┘
       │
       ▼  APPROVED or max_rounds reached
  Shutdown → TeamDelete → Report to user
```

## Verdict Rule

- **APPROVED** if all 6 axes are PASS or WARN (across both reviewers).
- **NEEDS_REVISION** if any single axis returns FAIL from any reviewer.

Axis ownership:
- `reviewer-content` covers: Decision Purity, Rationale Presence, Decision Maturity
- `reviewer-structure` covers: Context Budget, Constraint Quality, CLAUDE.md Alignment

## Max-Rounds Escalation

If round == max_rounds AND verdict is NEEDS_REVISION, do NOT loop further. Report to the user with three options:

```
## sketch-team — Max rounds reached

Rounds used: [max_rounds]
Current verdict: NEEDS_REVISION
Unresolved issues (by axis):
  [axis]: [brief issue summary]

Options:
1. **Continue** — run another round (re-invoke `/sketch-team -n N` with remaining effort budget)
2. **Accept as-is** — the current design is good enough; use it
3. **Rethink** — the design may be fundamentally wrong; consider reframing before iterating

Which would you like?
```

Wait for user response. Do not auto-iterate. Then proceed to shutdown.

## Shutdown

After final round (APPROVED or escalation resolved):

1. Send `shutdown_request` to each teammate:
```
SendMessage(
  type: "shutdown_request",
  recipient: "[TEAMMATE_NAME]",
  content: "Sketch complete. Shutting down."
)
```

2. Wait for all shutdown responses.

3. Delete the team:
```
TeamDelete()
```

4. Report final status to the user:
```
## Sketch Team Complete

**Status**: [APPROVED / NEEDS_REVISION escalation resolved]
**Rounds**: N / max_rounds
**Designers**: [designer_count] ([approach labels])
**Document**: [DOCUMENT_PATH]
**Review**: [REVIEW_PATH]

[Brief summary of the document's key decisions]
```

## Key Rules

- **Lead does NOT write files** — only the Scribe holds Write tool. Lead orchestrates via SendMessage only.
- **Lead does NOT judge design content** — that is the Reviewers' job. Lead only consolidates verdicts and applies the rule.
- **Phases are sequential per round** — Design → Write → Review → Consolidate. Each completes before the next begins.
- **Teammates stay alive across rounds** — do NOT shut down or respawn between rounds. Context is naturally preserved.
- **Planner never writes** — synthesizes approaches and returns draft text to Lead via SendMessage.
- **Designers never write** — return approach text via SendMessage, both preliminary and refined.
- **Reviewers never write** — return 3-axis verdicts via SendMessage only.
- **Approach labels must be distinct** — no two Designers in a round share the same label.
- **Never spawn more than 3 Designers** — the cap protects token budget and preserves cross-pollination coherence.
- **Resolve output path once** (Phase 0 dialogue), then reuse every round.
