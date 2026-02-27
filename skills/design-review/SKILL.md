---
name: design-review
description: This skill should be used when the user asks to "review my design", "score this design", "evaluate my design", "rate this design", "grade my design", "design quality check", "design audit", "check this design document", "설계 리뷰해줘", "설계 평가해줘", "이 설계 괜찮아?", "설계 점수 매겨줘", "설계 검토해줘", "디자인 리뷰해줘". Scores design documents against 6 vibe coding axes (decision purity, rationale, decision maturity, context budget, constraint quality, CLAUDE.md alignment) and outputs Grade (S~F), Score (0-100), and detailed feedback.
---

# Design Review

## Purpose

Score a design document against vibe coding principles. Output: Grade (S~F), Score (0-100), and actionable feedback per axis. Catch over-specification, missing decisions, and scope creep BEFORE implementation begins.

## Input

인자로 파일 경로가 전달되면 해당 문서를 평가 대상으로 한다. 인자가 없고, 유저가 대상 문서를 명시하지 않았으면 반드시 재질문할 것. **대상 문서가 확정되기 전에 평가를 시작하지 말 것.** 다른 문서를 자동 탐색하지 말 것. CLAUDE.md는 Axis 6 평가를 위해 읽는다.

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

**예외**: 사용자가 대화(Step 1.5)에서 명시적으로 확정한 기술/방식 선택은 구현 디테일이 아니라 설계 결정이다. 예: "WebSocket — because 사용자 결정"은 PASS. 판단이 어려우면 해당 항목이 사용자 결정인지 확인할 것.

### Axis 2: Rationale Presence

> Does each decision explain WHY? Are flow-based decisions visualized?

**PASS**: Every decision has a reason ("because...", "to ensure...", "so that...") or the reason is self-evident from context. 흐름이 있는 결정(주체 간 요청/응답, 상태 전이, 데이터 처리 과정)이 다이어그램으로 시각화되어 있음.
**WARN**: 1-2 decisions missing rationale. 또는 흐름이 있는 결정이 텍스트로만 기술되어 있고 다이어그램이 없음.
**FAIL**: Multiple decisions stated as bare facts without reasoning.

Detection: look for bare bullet points stating decisions without "because", "to ensure", "so that", or contextual justification. 또한 다음 패턴이 텍스트로만 기술되어 있는지 확인: 여러 주체 간 위임/호출 흐름, 상태 전이(Job 상태, 세션 라이프사이클), 다단계 데이터 처리 과정. 해당 패턴이 있는데 Mermaid 등 다이어그램이 없으면 WARN.

### Axis 3: Decision Maturity

> 확정 결정과 후보 항목이 명확히 구분되어 있는가?

**PASS**: 확정 결정에만 "because" 근거가 있고, 후보 항목은 별도 섹션에 근거 없이 목록으로 분리.
**WARN**: 후보 항목이 분리되어 있으나 일부에 "because" 근거가 달려있음 (과잉 확정).
**FAIL**: 확정/후보 구분이 없음. 모든 항목이 동일한 톤으로 작성.

Detection: 후보 항목("v0 이후 검토 방향" 등)에 "because", "— because" 패턴이 있는지 확인. 미래 가정에 기반한 근거("외부 사용자가 필요하므로", "장기 운영 시")가 확정 결정처럼 쓰여있는지 확인.

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

**예외**: 사용자가 대화에서 특정 기술을 선택한 경우, 그 기술명이 제약 조건에 포함되는 것은 처방이 아니라 결정이다. 예: "WebSocket 사용 — because 사용자 결정: 실시간 필요"는 PASS.

### Axis 6: CLAUDE.md Alignment

> CLAUDE.md가 설계 문서에 링크하고, 설계 내용을 복제하지 않으며, 참조 테이블의 스코프 설명이 실제 문서 내용과 일치하는가?

**PASS**: CLAUDE.md가 설계 문서를 링크(참조 시점 포함)하고, 기술 스택/규칙만 팩트로 포함. 설계 내용(아키텍처, 상태 머신, 도구 목록)은 설계 문서에만 있음. 참조 테이블의 "참조 시점" 설명이 실제 설계 문서의 주요 섹션/스코프와 일치.
**WARN**: 설계 문서 링크가 없거나, 일부 설계 내용이 CLAUDE.md에 중복. 또는 참조 테이블의 스코프 설명이 실제 설계 문서 내용과 불일치(설계 문서에 추가된 스코프가 참조 시점에 반영되지 않음).
**FAIL**: CLAUDE.md에 아키텍처 다이어그램, 상태 머신, 도구 목록 등 설계 내용이 복제되어 있음.

Detection: CLAUDE.md에 설계 문서 링크 테이블이 있는지 확인. 아키텍처 설명, 상태 전이, 도구 목록이 CLAUDE.md에 직접 기술되어 있으면 FAIL. 참조 테이블이 있으면 각 설계 문서의 주요 섹션 제목과 참조 시점 설명을 대조하여 누락된 스코프가 없는지 확인. Skip this axis if the design is a draft not yet approved (state this explicitly in output).

---

## Step 2: Calculate Score and Grade

**Score** = (sum of axis points / max possible points) × 100, rounded to integer. Max possible points = 12 (6 axes × 2 points). If Axis 6 is skipped (draft document), max possible points = 10 (5 axes × 2 points).

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
| Decision Maturity | PASS/WARN/FAIL | 2/1/0 |
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

## Step 4: Cross-Document Check

When reviewing 2+ documents, perform a cross-document check after individual reviews. Skip this step for single-document reviews.

1. Collect all decision items from every target document.
2. For each decision, ask: **"Does this decision belong in another target document's scope (title, first sentence) but is missing there?"**
3. If suspected omissions exist, output the table below. If none, state "No suspected omissions."

Output format (appended after individual review results):

```
### Cross-Document Check

| Decision | Found in | Suspected missing from | Reason |
|----------|----------|----------------------|--------|
| [decision] | [document where it exists] | [document where it's missing] | [scope-matching rationale] |
```

Note: The same decision appearing in multiple documents at different abstraction levels is NOT duplication. Only flag omissions.

## Edge Cases

- **대상 문서 미지정**: 유저에게 재질문. 자동 탐색하지 말 것.
- **설계 불필요한 요구사항에 설계 문서가 존재**: Scope Check에서 걸러졌어야 할 단순 작업에 대해 설계 문서가 작성됨 — 과잉 설계 경고.
- **Design is intentionally detailed for a complex domain**: Complexity justifies more DECISIONS, not more IMPLEMENTATION details. Principles still apply.
- **3+ review rounds already**: The document likely contains too much implementation detail. Read `references/review-cycle-warning.md` and flag this in the assessment.

## Additional Resources

### Reference Files

- **`references/review-cycle-warning.md`** — Warning signs when review cycles indicate over-specification

### Examples

- **`examples/sample-review.md`** — Complete review output example with mixed grades for calibration
