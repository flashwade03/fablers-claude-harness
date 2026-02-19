---
name: design-review
description: This skill should be used when the user explicitly asks to "review my design", "score this design", "evaluate my design", "rate this design", "design quality check", "설계 리뷰해줘", "설계 평가해줘", "이 설계 괜찮아?", "설계 점수 매겨줘". Scores design documents against 6 vibe coding axes (decision purity, rationale, milestone scope, context budget, constraint quality, CLAUDE.md alignment) and outputs Grade (S~F), Score (0-100), and detailed feedback.
---

# Design Review

## Purpose

Score a design document against vibe coding principles. Output: Grade (S~F), Score (0-100), and actionable feedback per axis. Catch over-specification, missing decisions, and scope creep BEFORE implementation begins.

## Input

Read the design document the user points to. If no specific file is given, check `docs/plans/` (project convention) for the most recent design document. If that path does not exist, ask the user to specify the file. Also read the project's CLAUDE.md for Axis 6 cross-reference.

## Step 1: Score Each Axis

Evaluate the document against 6 axes. Each axis gets one of three grades:

| Grade | Points | Meaning |
|-------|--------|---------|
| PASS | 2 | Meets the principle. No action needed. |
| WARN | 1 | Minor issues. Fixable without restructuring. |
| FAIL | 0 | Violates the principle. Must fix before implementation. |

---

### Axis 1: Decision Purity

> Does every statement describe a DECISION or CONSTRAINT — not implementation?

**PASS**: All statements are "what" and "why" — no "how."
**WARN**: 1-2 implementation details that could be stripped.
**FAIL**: Contains pseudocode, function signatures, DB schemas, API formats, or implementation patterns.

Detection: scan for code blocks, function names with parentheses, type annotations, variable names, specific library API calls.

### Axis 2: Rationale Presence

> Does each decision explain WHY?

**PASS**: Every decision has a reason ("because...", "to ensure...", "so that...") or the reason is self-evident from context.
**WARN**: 1-2 decisions missing rationale.
**FAIL**: Multiple decisions stated as bare facts without reasoning.

Detection: look for bare bullet points stating decisions without "because", "to ensure", "so that", or contextual justification.

### Axis 3: Milestone Scope

> Does the document cover exactly ONE milestone?

**PASS**: Clear single milestone. Out-of-scope items explicitly listed.
**WARN**: Scope section exists but some decisions belong to future milestones.
**FAIL**: No scope section, or document covers the entire system lifecycle.

Detection: look for error recovery, monitoring, scaling, graceful shutdown in a v0 document. Look for missing "Out of scope" section.

### Axis 4: Context Budget

> Will the actionable content fit in ~200-300 lines?

**PASS**: Under 200 lines of decisions and constraints.
**WARN**: 200-400 lines. Could be trimmed.
**FAIL**: Over 400 lines. Likely contains implementation details or multi-milestone scope.

Detection: count substantive lines only (exclude template headers, blank lines, markdown formatting).

### Axis 5: Constraint Quality

> Are constraints stated as boundaries, not prescriptions?

**PASS**: Constraints say what must/must not happen, leaving implementation to AI.
**WARN**: 1-2 constraints that prescribe specific libraries or patterns.
**FAIL**: Multiple constraints that dictate implementation choices.

Detection: look for specific library names, framework APIs, or file path patterns stated as constraints. Boundary = "실시간 통신이 필요하다". Prescription = "WebSocket을 사용하여 Express에서...".

### Axis 6: CLAUDE.md Alignment

> Are the design's resulting facts reflected in CLAUDE.md?

**PASS**: Tech stack, rules, folder structure in CLAUDE.md match the design's decisions.
**WARN**: Minor gaps — a new technology or rule not yet reflected.
**FAIL**: Design introduces major architectural elements absent from CLAUDE.md, OR CLAUDE.md contains design rationale/narrative instead of facts.

Detection: cross-reference the design's tech stack, directory structure, and rules against CLAUDE.md sections. Skip this axis if the design is a draft not yet approved (state this explicitly in output).

---

## Step 2: Calculate Score and Grade

**Score** = (sum of axis points / 12) × 100, rounded to integer.

**Grade** is determined by FAIL count first, then score:

| Condition | Grade |
|-----------|-------|
| All 6 PASS | S |
| 0 FAIL, score >= 83 | A |
| 0 FAIL, score >= 67 | B |
| 1 FAIL | C (capped regardless of score) |
| 2 FAIL | D |
| 3+ FAIL | F |

Any single FAIL caps the grade at C. Design documents with FAIL items should not proceed to implementation.

## Step 3: Output

Use this exact format:

```
## Design Review

**Grade: [S~F]** | **Score: [0-100]**

[1-2 sentence overall assessment]

### Axis Scores

| Axis | Grade | Points |
|------|-------|--------|
| Decision Purity | PASS/WARN/FAIL | 2/1/0 |
| Rationale Presence | PASS/WARN/FAIL | 2/1/0 |
| Milestone Scope | PASS/WARN/FAIL | 2/1/0 |
| Context Budget | PASS/WARN/FAIL | 2/1/0 |
| Constraint Quality | PASS/WARN/FAIL | 2/1/0 |
| CLAUDE.md Alignment | PASS/WARN/FAIL | 2/1/0 |

### Feedback

#### [Axis Name]: [WARN/FAIL]

> [Quoted line(s) from document]

**Problem**: [Which principle is violated]
**Fix**: [Specific action — remove, rewrite, or move to out-of-scope]

(Repeat for each non-PASS axis. Skip PASS axes.)

### Action Items
1. [Most critical fix]
2. [Next fix]
...
```

For a complete example of review output, see `examples/sample-review.md`.

## Edge Cases

- **No design document exists**: Suggest the user run the vibe-design skill first.
- **Level 0/1 requirement with a Level 2 document**: FAIL on Milestone Scope — the requirement didn't need a document.
- **Design is intentionally detailed for a complex domain**: Complexity justifies more DECISIONS, not more IMPLEMENTATION details. Principles still apply.
- **3+ review rounds already**: The document likely contains too much implementation detail. Read `references/review-cycle-warning.md` and flag this in the assessment.

## Additional Resources

### Reference Files

- **`references/review-cycle-warning.md`** — Warning signs when review cycles indicate over-specification

### Examples

- **`examples/sample-review.md`** — Complete review output example with mixed grades for calibration
