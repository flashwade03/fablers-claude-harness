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

## Phase 1: Design (Planner manages Designers)

### Round 1 (Initial Draft)

Send the decision sheet to the planner. The planner manages designers internally — Lead does not communicate with designers directly.

**To planner:**
```
SendMessage(
  type: "message",
  recipient: "planner",
  content: "ROUND 1 — DESIGN PHASE

Task: [TASK_DESCRIPTION]
Target document: [DOCUMENT_PATH]
Designers: [designer-1 (approach-[LABEL]), designer-2 (approach-[LABEL]), ...]

--- DECISION SHEET ---
## Confirmed Decisions
[Paste the full 'Confirmed Decisions' section from Phase 0's sheet verbatim — each line of the form '- [Decision]: [what] — because [why]'.]

## Open Decisions (autonomous)
[Paste the full 'Open Decisions' section verbatim — each line a bullet for a technical choice still open to Planner/Designer judgement.]

## Target Document
Path: [DOCUMENT_PATH]
Action: [create new | update existing]
--- END ---

Instructions:
1. Send each designer their approach label and the decision sheet — ask each for a preliminary approach centered on that label
2. Collect preliminary approaches from all designers — wait until all have reported
3. Cross-pollinate: build a per-designer summary of peer approaches and send with a gap-check prompt — ask each designer how their approach changes given what peers found
4. Collect refined approaches from all designers
5. Synthesize the refined approaches into a unified draft that honours the Confirmed Decisions and resolves Open Decisions
6. Send the unified draft text to 'team-lead' via SendMessage",
  summary: "Round 1 design"
)
```

**Draft collection:**

Planner manages Designers autonomously — Lead does NOT intervene. Wait for the draft to arrive as a SendMessage from `planner` addressed to `team-lead`.

When received, extract the draft content. This is what the Scribe will write.

### Round 2+ (Revision)

Include consolidated review feedback from the previous round:

```
SendMessage(
  type: "message",
  recipient: "planner",
  content: "ROUND [N] — REVISION PHASE

Previous verdict: NEEDS_REVISION

Failed axes (from .review.md):
[LIST of axes that failed + issues — keep it concise, ≤1 line per axis]

Review History:
[REVIEW_HISTORY_TABLE from .review.md]

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
   - Decision Purity — Every statement is a decision, not implementation (no pseudocode, no function signatures)
   - Rationale Presence — Every confirmed decision explains why (because…). Candidate items stay without rationale.
   - Decision Maturity — Confirmed decisions and candidate items are clearly separated and follow the rules in the vibe-design skill (confirmed has because; candidate does not)
3. For each axis, include a brief explanation + concrete line references when possible
4. Return a structured verdict (below) to 'team-lead' (use EXACTLY recipient: 'team-lead')

Verdict format:
| Axis | Verdict | Notes |
|------|---------|-------|
| Decision Purity | PASS/WARN/FAIL | [1-2 lines, cite line numbers for issues] |
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

Instructions:
1. Read the document at [DOCUMENT_PATH]
2. Evaluate 3 axes with PASS / WARN / FAIL for each:
   - Context Budget — Fits in ~200–300 lines of the core doc. Overflow goes into reference files, not the main doc.
   - Constraint Quality — Constraints express boundaries (must / must not) rather than prescriptions for implementation details
   - CLAUDE.md Alignment — The design doc is referenced by CLAUDE.md (link or pointer), not duplicated. No architecture / state machines / tool inventories in CLAUDE.md itself.
3. For each axis, include a brief explanation + concrete line references when possible
4. Return a structured verdict (below) to 'team-lead' (use EXACTLY recipient: 'team-lead')

Verdict format:
| Axis | Verdict | Notes |
|------|---------|-------|
| Context Budget | PASS/WARN/FAIL | ... |
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

After determining verdict, consolidate both reviews and send to the scribe.

```
SendMessage(
  type: "message",
  recipient: "scribe",
  content: "CONSOLIDATE PHASE — Round [N]

Document path: [DOCUMENT_PATH]
Review file path: [REVIEW_PATH]
Round: [N]
Verdict: [APPROVED | NEEDS_REVISION]

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

- **Single Designer** (designer_count = 1): Planner sends the assignment to designer-1, receives the preliminary approach, skips cross-pollination (no peers to summarise), then asks designer-1 to refine based on the decision sheet alone. Refined approach becomes the draft directly.
- **Designer timeout / no response**: If a designer does not respond within a reasonable window, Planner should note the gap in its synthesis and proceed with the remaining approaches. Planner flags this condition to Lead in the draft submission so Lead can mention it in the final report.
- **Designers converge to same approach**: If refined approaches from multiple designers are nearly identical, Planner synthesizes them as a single approach with stronger rationale rather than forcing artificial diversity.
- **Reviewer disagreement between axes**: If an axis is PASS by one reviewer and FAIL by the other, Lead treats it as FAIL (any FAIL caps the verdict). The reviewer's reasoning is recorded so the Planner can address both perspectives in the revision.
- **Draft exceeds context budget before Phase 3**: Reviewer-structure will catch this as Context Budget FAIL in Round 1 — no special Lead intervention needed.
