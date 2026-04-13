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

### 0. Resolve Plugin Root

Before doing anything else, resolve the plugin root (needed for reading vibe-design):

```
Bash(command: "echo $CLAUDE_PLUGIN_ROOT")
```

If empty, derive from this skill file's location — strip `/skills/sketch-team-orchestrator/SKILL.md` from the path. Store as `PLUGIN_ROOT` and reuse throughout the entire invocation (both Phase 0 and Phase 1).

### Run vibe-design dialogue

Read `${PLUGIN_ROOT}/skills/vibe-design/SKILL.md` and execute **only** steps 0.5 (target doc confirmation), 1 (Scope Check), and 1.5 (idea exploration dialogue). Skip steps 2–7 — the team handles those phases.

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

### Validate the Decision Sheet

Before proceeding to Phase 1, verify the sheet is usable:

- At least one item under **Confirmed Decisions** (user dialogue actually produced something)
- Each Confirmed Decision has a `because …` rationale
- Target document path is resolved (absolute or project-relative, no placeholders)
- Scope Check completed (not "설계 불필요")

If any check fails, ask the user the specific missing piece rather than spawning a team with an incomplete sheet. Do NOT proceed to Phase 1 until the sheet is complete.

## Phase 1 — Team Setup (one-time)

(`PLUGIN_ROOT` is already resolved from Phase 0 Step 0 — reuse it.)

### 1. Decide Designer Count and Approach Labels

From the Confirmed + Open Decisions sheet, identify the **contested trade-off space**:
- If there are 2–3 genuinely different ways to approach the core structural problem (e.g., WebSocket vs SSE vs polling; monolith-first vs service-boundary-first; eager-load vs lazy-load) → assign one Designer per approach, `designer_count = 2` or `3`
- If the direction is essentially settled and only details remain → `designer_count = 1`
- **Default when no clear trade-offs surfaced in dialogue**: `designer_count = 1`. Do not invent artificial approach axes just to justify more Designers — single-Designer is the honest answer when the dialogue already resolved the structural direction.

Assign each Designer a **distinct approach label** that summarises their directional frame. Examples:
- `approach-conservative` (prefer proven patterns, lowest risk)
- `approach-balanced` (mainstream choice for this domain)
- `approach-minimal` (smallest-viable surface, YAGNI-first)
- `approach-aggressive` (optimised for future scale)
- domain-specific labels when the axis is clearer (e.g., `approach-websocket`, `approach-sse`)

**Cap: never spawn more than 3 Designers.**

### 2. Assign Models

Hardcoded for v0:
- `designer-[N]`: sonnet
- `planner`: sonnet
- `scribe`: haiku
- `reviewer-content`: haiku
- `reviewer-structure`: haiku

### 3. Create Team

```
TeamCreate(
  team_name: "sketch-team",
  description: "Sketching: [TASK_DESCRIPTION]"
)
```

The `TeamCreate` call registers the current agent (you) as `team-lead` automatically — this is the built-in Agent Teams convention. All teammates address you via `recipient: "team-lead"` and you use that inbox to receive their messages.

### 4. Spawn Teammates

**MANDATORY**: Before spawning, `Read("references/teammate-prompts.md")`. Use the exact text from each `Spawn prompt:` code block as the `prompt` parameter — do not write prompts from memory.

Spawn all teammates in a single message (parallel Agent calls). Each joins the team via `team_name: "sketch-team"`.

**Designers** — iterate `N` from 1 through `designer_count` and issue one `Agent(...)` call per Designer. For `designer_count = 2`, that means two Agent calls named `designer-1` and `designer-2`, each with its assigned approach label:
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
1. **Continue** — end this invocation, then re-run `/sketch-team -n N <same task>` to grant additional rounds. The current `[design].md` + `.review.md` are preserved, so the next invocation can start from the current state.
2. **Accept as-is** — the current design is good enough; use the `[design].md` as it stands
3. **Rethink** — the design may be fundamentally wrong; stop iterating and reframe the task before a future invocation

Which would you like?
```

Wait for user response. Do NOT auto-iterate within this invocation. The current invocation ends after this response regardless of which option is chosen:

- **Continue**: proceed to shutdown and tell the user to re-invoke the command (Lead cannot restart itself mid-session)
- **Accept as-is**: proceed to shutdown; the design doc is final
- **Rethink**: proceed to shutdown; the user is expected to re-engage later with a reframed task

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
