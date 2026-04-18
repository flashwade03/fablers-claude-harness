# Round Flow — Detailed Steps

> `[PLUGIN_ROOT]` below refers to the resolved plugin root path from Phase 1 Step 1 in SKILL.md. Substitute the actual path in all SendMessage content.

## Path Variable Derivation

All placeholders below are derived from `[DOCUMENT_PATH]` resolved during Phase 0 dialogue:

- `[DOCUMENT_PATH]` — full path, e.g., `docs/features/notifications.md`
- `[DOCUMENT_DIR]` — directory portion: everything before the final `/`, e.g., `docs/features`
- `[DOCUMENT_NAME]` — basename with extension: everything after the final `/`, e.g., `notifications.md`
- `[DOCUMENT_STEM]` — basename without extension: `[DOCUMENT_NAME]` minus trailing `.md`, e.g., `notifications`
- `[REVIEW_PATH]` — `.review.md` path, computed as `[DOCUMENT_DIR]/[DOCUMENT_STEM].review.md`, e.g., `docs/features/notifications.review.md`

Lead computes these once after Phase 0 and reuses them across all rounds.

## Phase 1: Design (Planner manages Specialists)

### Round 1 (Initial Draft)

Send the decision sheet to the planner. The planner manages Specialists internally — Lead does not communicate with Specialists directly.

**To planner:**
```
SendMessage(
  type: "message",
  recipient: "planner",
  content: "ROUND 1 — DESIGN PHASE

Task: [TASK_DESCRIPTION]
Target document: [DOCUMENT_PATH]
Specialist roster: [specialist-[ROLE_1] (one-line role description), specialist-[ROLE_2] (one-line role description), ...]
Critic mode: [single | per-specialist]
Challenger roster: [challenger]  or  [challenger-[ROLE_1], challenger-[ROLE_2], ...]

--- DECISION SHEET ---
## Confirmed Decisions
[Paste the full 'Confirmed Decisions' section from Phase 0's sheet verbatim — each line of the form '- [Decision]: [what] — because [why]'.]

## Open Decisions (autonomous)
[Paste the full 'Open Decisions' section verbatim — each line a bullet for a technical choice still open to Planner/Specialist judgement.]

## Target Document
Path: [DOCUMENT_PATH]
Action: [create new | update existing]
--- END ---

Instructions:
1. Send each Specialist their role label + role description and the decision sheet — ask each for a preliminary domain artifact
2. Collect preliminary artifacts from all Specialists — wait until all have reported
3. Route preliminary artifacts to Challenger(s):
   - If critic_mode = single: send ALL preliminary artifacts to 'challenger' in one message for cross-cutting critique (per-specialist breakdown)
   - If critic_mode = per-specialist: send each Specialist's artifact to its paired 'challenger-[ROLE]' for domain-focused critique
4. Collect critique(s) from Challenger(s) — each names (a) weakest assumption, (b) alternative framing, (c) missed edge case per Specialist
5. Coherence state: note cross-domain conflicts between Specialists (type mismatches, ordering disagreements) — only applies when count ≥ 2
6. Send ONE integrated message per Specialist: peer summary (if count ≥ 2) + cross-domain conflicts + Challenger critique + instruction to adjust OR reject with 1-line reason
7. Collect refined artifacts from all Specialists — each refines to address critique/peers, either adopting or rejecting-with-reason
8. Compose the refined artifacts into a unified draft that:
   - Honours Confirmed Decisions (non-negotiable)
   - Includes concrete artifacts from each Specialist in their natural sections (Data Models, Interfaces, Sequence Diagrams, etc.)
   - Records every rejected-with-reason Challenger alternative inline as 'Alternative considered: X — rejected because Y' next to the winning decision
   - Surfaces any [OPEN QUESTION FOR USER] from Challenger(s) in an 'Open Questions for User' section
9. Send the composed draft text to 'team-lead' via SendMessage",
  summary: "Round 1 design"
)
```

**Draft collection:**

Planner manages Specialists autonomously — Lead does NOT intervene. Wait for the draft to arrive as a SendMessage from `planner` addressed to `team-lead`.

When received, extract the draft content. This is what the Scribe will write.

### Round 2+ (Revision)

Include consolidated review feedback from the previous round. Lead has the verdicts in memory from the previous round's Phase 3 — use those directly. Do NOT re-read `.review.md` (it is the audit artifact, not Lead's working state).

```
SendMessage(
  type: "message",
  recipient: "planner",
  content: "ROUND [N] — REVISION PHASE

Previous verdict: NEEDS_REVISION

Failed axes:
[LIST of axes that failed + issues from previous round — keep it concise, ≤1 line per axis. Source: in-memory verdicts from previous round's Phase 3.]

Action required:
[Lead's revision instructions for this round — same content Lead passed to Scribe in the previous round's Phase 4 (the 'Action required' field).]

Review History (rounds 1..N-1):
[Brief summary of each prior round's verdict + key failed axes — ≤1 line per round.]

Instructions:
1. Re-engage designers only if specific approaches need revisiting to fix the failed axes
2. If fixes are structural/textual and do not need cross-pollination, revise the draft directly
3. Send the revised draft text to 'team-lead'",
  summary: "Round [N] revision"
)
```

## Phase 2: Writing

After receiving the draft from the planner, send it to the scribe with the output path.

```
SendMessage(
  type: "message",
  recipient: "scribe",
  content: "WRITE PHASE — Round [N]

Output path: [DOCUMENT_PATH]

--- DRAFT CONTENT ---
[DRAFT_CONTENT from planner]
--- END ---

Instructions:
1. If the file already exists at [DOCUMENT_PATH], Read it first (required before Write)
2. Polish for consistency and flow — preserve every decision and constraint from the draft
3. Write the polished document using the Write tool
4. Confirm to 'team-lead' with the final file path",
  summary: "Write document round [N]"
)
```

Wait for scribe to confirm before proceeding to review.

## Phase 3: Review

Send review instructions to both reviewers simultaneously (single message with parallel SendMessage calls). Each reviewer works independently.

**To reviewer-content:**
```
SendMessage(
  type: "message",
  recipient: "reviewer-content",
  content: "REVIEW PHASE — Round [N]

Document: [DOCUMENT_PATH]

Instructions:
1. Read the document at [DOCUMENT_PATH]
2. Evaluate 3 axes with PASS / WARN / FAIL for each:
   - Specification Productivity — Concrete artifacts (signatures, schemas, sequence diagrams, code blocks) must be load-bearing (pin down a decision prose alone wouldn't). Decorative pseudocode that just translates English to code-shaped text without adding decision content → FAIL.
   - Rationale Presence — Every confirmed decision AND every concrete spec choice has a 'because …' clause. Candidate items in 'v0 이후 검토 방향' stay without rationale.
   - Decision Maturity — Confirmed decisions and candidate items are structurally separated; confirmed has because, candidate does not.
3. For each axis, include a brief explanation + concrete line references; for Specification Productivity FAIL, name the decorative artifacts.
4. Return a structured verdict (below) to 'team-lead' (use EXACTLY recipient: 'team-lead')

Verdict format:
| Axis | Verdict | Notes |
|------|---------|-------|
| Specification Productivity | PASS/WARN/FAIL | ... |
| Rationale Presence | PASS/WARN/FAIL | ... |
| Decision Maturity | PASS/WARN/FAIL | ... |",
  summary: "Content review round [N]"
)
```

**To reviewer-structure:**
```
SendMessage(
  type: "message",
  recipient: "reviewer-structure",
  content: "REVIEW PHASE — Round [N]

Document: [DOCUMENT_PATH]
Specialist roster (this round): [LIST of specialist roles, e.g., data-model, api-surface]

Instructions:
1. Read the document at [DOCUMENT_PATH]
2. Read CLAUDE.md at the project root if it exists (for CLAUDE.md Alignment axis)
3. Evaluate 3 axes with PASS / WARN / FAIL for each:
   - Specialist Coherence — Domain artifacts produced by different specialists compose without contradiction (no type mismatches, no ordering / lifecycle conflicts, no missing cross-domain handoffs). If only one specialist participated, this axis is automatically PASS.
   - Constraint Quality — Constraints express boundaries (must / must not). Concrete spec is allowed when it IS the constraint (e.g., 'must accept ISO-8601 UTC timestamps'). Prescriptive constraints that micromanage implementation choice → FAIL.
   - CLAUDE.md Alignment — Design doc is referenced from CLAUDE.md (link / table row), not duplicated. If CLAUDE.md is absent, this axis is PASS but flag it.
4. For each axis, include a brief explanation + concrete line references; for Specialist Coherence FAIL, name the contradicting domains.
5. Return a structured verdict (below) to 'team-lead' (use EXACTLY recipient: 'team-lead')

Verdict format:
| Axis | Verdict | Notes |
|------|---------|-------|
| Specialist Coherence | PASS/WARN/FAIL | ... |
| Constraint Quality | PASS/WARN/FAIL | ... |
| CLAUDE.md Alignment | PASS/WARN/FAIL | ... |",
  summary: "Structure review round [N]"
)
```

**Review collection — Lead determines verdict:**

Track received reviews:
- reviewer-content: ☐ → ☑
- reviewer-structure: ☐ → ☑

When BOTH have replied, apply the verdict rule:

- **APPROVED** if every axis across both reviewers is PASS or WARN
- **NEEDS_REVISION** if any single axis is FAIL

## Phase 4: Consolidate Review File

After determining verdict, Lead first **constructs the action-required summary** itself (a short revision plan derived from the failed axes), then consolidates both reviews + the action summary and sends to the scribe.

For APPROVED rounds: action required is `"none — APPROVED"`.
For NEEDS_REVISION rounds: action required is a 1–3 line revision plan (e.g., "Move pseudocode in Tag Storage section to constraints; add rationale to scope decision; trim Examples to fit Context Budget"). This is the same content Lead will reuse when constructing Round N+1's Planner message.

```
SendMessage(
  type: "message",
  recipient: "scribe",
  content: "CONSOLIDATE PHASE — Round [N]

Document path: [DOCUMENT_PATH]
Review file path: [REVIEW_PATH]
Round: [N]
Verdict: [APPROVED | NEEDS_REVISION]

Action required: [Lead's 1–3 line revision plan, or 'none — APPROVED']

--- CONTENT REVIEW (reviewer-content) ---
[CONTENT_REVIEW_TABLE]
--- END ---

--- STRUCTURE REVIEW (reviewer-structure) ---
[STRUCTURE_REVIEW_TABLE]
--- END ---

Instructions:
1. If round > 1: Read existing .review.md first
   - Preserve all Review History rows
   - Compress previous 'Current Iteration' into a new history row (verdict + failed axes in ≤15 words)
2. Write the .review.md with this structure:

---
document_file: [DOCUMENT_NAME]
revision: [N]
reviewed_at: [ISO timestamp]
reviewers: [reviewer-content, reviewer-structure]
verdict: [APPROVED | NEEDS_REVISION]
---

# Design Review — [DOCUMENT_NAME]

## Review History (round > 1 only)
| Round | Verdict | Failed axes (≤15 words) |
|-------|---------|--------------------------|
| 1 | ... | ... |
| 2 | ... | ... |

## Current Iteration — Round [N]

### Content (reviewer-content)
[CONTENT_REVIEW_TABLE]

### Structure (reviewer-structure)
[STRUCTURE_REVIEW_TABLE]

### Consolidated
- Overall verdict: [APPROVED | NEEDS_REVISION]
- Failed axes: [list, or 'none']
- Action required: [summarized revision instructions, or 'none — APPROVED']

3. Confirm to 'team-lead' with the review file path",
  summary: "Write review file round [N]"
)
```

Wait for scribe to confirm.

## Phase 5: Loop or Complete

**If APPROVED:**
→ Proceed to shutdown (see SKILL.md Shutdown section).

**If NEEDS_REVISION and round < max_rounds:**
→ Return to Phase 1 (Round N+1) with revision feedback.

**If NEEDS_REVISION and round == max_rounds:**
→ Do NOT loop. Escalate to user (see SKILL.md Max-Rounds Escalation section). After user responds, proceed to shutdown — the escalation response is final for this invocation.

## Edge Cases

- **Single Specialist** (count = 1): Planner sends the assignment to that one Specialist, receives the preliminary artifact, skips coherence-check (no peers), then asks the Specialist to refine against the decision sheet alone. Refined artifact becomes the draft (with light editorial polish from Planner). Specialist Coherence axis is auto-PASS.
- **Specialist timeout / no response**: If a Specialist does not respond within a reasonable window, Planner notes the gap in its draft submission (which sections of the doc are missing). Planner flags this condition to Lead so Lead can mention it in the final report. Reviewers will likely flag the missing domain on Specialist Coherence or Spec Productivity.
- **Cross-domain conflict can't be resolved in coherence-check**: If two Specialists have a conflict that neither can yield on (e.g., data-model insists UUIDs are required but api-surface requires sortable IDs), Planner falls back to the **Confirmed Decisions** as tiebreaker. If Confirmed Decisions don't decide it, Planner picks the resolution that minimises change to peer artifacts and notes the override in the draft so the next round's review can sanity-check it.
- **Reviewer disagreement between axes**: If an axis is PASS by one reviewer and FAIL by the other, Lead treats it as FAIL (any FAIL caps the verdict). The reviewer's reasoning is recorded so the Planner can address both perspectives in the revision.
- **Draft length overshoot**: Reviewers don't enforce a hard length cap (the rubric replaced Context Budget with Specialist Coherence). If the core draft exceeds ~600 lines, Planner should consider offloading deep details to reference files in the next round, but this is a soft target — concrete artifacts that genuinely need the lines stay in.
