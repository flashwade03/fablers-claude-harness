---
name: sketch-team
description: "Concrete multi-domain design workflow via Agent Teams — Specialist Designers (1-3 domains, Lead-decided) produce concrete artifacts, a Challenger adversarially critiques them, a Planner composes with cross-domain coherence checks, a Scribe writes, two Reviewers judge against a concretion-friendly 6-axis rubric, loop until approved."
argument-hint: "[-n max] [-o path] [-c] <task description>"
---

# Sketch Team

Produce a **concrete, multi-domain design document** using Agent Teams. Where `/sketch` (vibe-design alone) keeps decisions abstract so AI fills in implementation later, `/sketch-team` deliberately concretises: interfaces, data shapes, sequence diagrams, error patterns. Use it when the concretion itself *is* the decision (API contracts, message protocols, data models with cascading type implications).

Lead conducts a dialogue with you first (vibe-design Step 0.5–1.5 — target doc confirmation + user-only decisions) before the team spawns. Then Lead picks 1–3 Specialist Designers based on the task's natural domain decomposition (e.g., `data-model`, `api-surface`, `protocol`, `error-handling`, `operations`). The team handles concretion + cross-domain composition + review autonomously.

## Workflow

1. **Lead dialogue** — confirms target doc + locks user-only decisions (UX, scope, priorities) via vibe-design Step 0.5–1.5
2. **Specialist Designers** (1–3, Lead picks domains from task) → produce preliminary concrete domain artifacts
3. **Challenger(s)** → read preliminary artifacts and produce adversarial critique per Specialist (weakest assumption / alternative framing / missed edge case). Default: one Challenger reads all; with `-c`: one Challenger per Specialist (deeper per-domain scrutiny).
4. **Planner** → integrate peer summary + critique into one coherence-check message per Specialist; collect refined artifacts; compose unified draft with inline `Alternative considered: X — rejected because Y` for rejected Challenger points
5. **Scribe** → write design doc to output path
6. **Reviewers** (Content + Structure) → judge against the concretion-friendly 6-axis rubric (Specification Productivity / Rationale Presence / Decision Maturity / Specialist Coherence / Constraint Quality / CLAUDE.md Alignment)
7. **Lead** → consolidate; any FAIL → NEEDS_REVISION else APPROVED
8. **Scribe** → write `.review.md` with round history
9. **Loop** → If NEEDS_REVISION and rounds remain, Planner revises with consolidated feedback. Max rounds → escalate to user.

## Usage

```
/sketch-team [-n max] [-o output_path] [-c] [task description]
```

- `-n`: Maximum rounds (default: 3)
- `-o`: Output file path (optional — if omitted, resolved from project conventions or asked during Lead dialogue)
- `-c`: Per-specialist critic mode — spawn one Challenger per Specialist (deeper but more expensive). Default (no flag): single Challenger covers all Specialists.

Examples:
```
/sketch-team design a job queue that handles retries and priorities
/sketch-team -n 5 architect multi-tenant data isolation
/sketch-team -c design a distributed cache invalidation protocol
/sketch-team -o docs/features/notifications.md design the notification system
```

---

**Instructions:** Follow the `sketch-team-orchestrator` skill to execute this workflow.

**Parse arguments:**
- Extract `-n [number]` if present → `max_rounds` (default: 3)
- Extract `-o [path]` if present → `output_path` (default: none)
- Extract `-c` (no value) if present → `critic_mode = "per-specialist"` (default: `critic_mode = "single"`)
- Remaining text → `task_description`

**User input:** $ARGUMENTS
