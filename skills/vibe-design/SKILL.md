---
name: vibe-design
description: This skill should be used when the user explicitly asks to "design a feature", "create architecture", "plan a system", "how much design do I need?", "should I write a spec?", "is this over-engineered?", "설계해줘", "아키텍처 잡아줘", "설계 범위 정해줘", "기획 문서 써야 할까?". This skill must be explicitly invoked — do NOT trigger automatically before plan mode or implementation. Guides design scope to match requirement size using 3 levels (no design, inline design, document design), preventing over-specification that kills vibe coding productivity.
---

# Vibe Design

## Purpose

Guide the design process to produce exactly the right amount of specification for vibe coding. Design = Decisions + Constraints + Milestones. Never pseudocode, function signatures, or exhaustive error paths.

Over-specification is as harmful as under-specification. Pseudocode in design documents creates consistency problems that require endless review cycles. AI can generate implementation from decisions — specifying implementation details constrains AI and introduces bugs that wouldn't exist otherwise.

## Step 0: Confirm Input Documents

대상 문서를 유저에게 확인할 것. 유저가 명시하지 않으면 재질문.

- 유저가 `@docs/features/` 등으로 지정 → 해당 파일만 작업 대상
- 지정 없이 "설계해줘" → "어떤 문서/영역을 대상으로 할까요?" 재질문
- 해당 영역에 기존 설계 문서가 있으면 → 새 파일을 만들지 말고 기존 문서를 업데이트. 새 파일 생성이 필요한지 유저에게 확인할 것.
- **전달받은 문서 외 다른 문서를 참조해서 스코프를 판단하지 말 것.** 다른 문서 참조가 필요하면 유저에게 물어볼 것.

## Step 1: Determine Scope Level

Before any design work, classify the requirement:

### Level 0: No Design Needed

**Condition**: Requirement completes within existing code structure.

- Bug fixes, text changes, style adjustments, config tweaks
- No new architectural decisions required

**Action**: Implement directly. No design document, no design discussion.

### Level 1: Inline Design

**Condition**: New feature that extends existing architecture through established patterns.

- Adding a component, endpoint, or handler where the pattern already exists
- Extension points are already in place

**Action**: State constraints directly in the implementation prompt. No separate document.

Format:
```
"[Feature description].
- [Key decision 1]
- [Key decision 2]
- Constraint: [what must/must not happen]"
```

### Level 2: Document Design

**Condition**: New structural decisions needed that downstream features will depend on.

- New project initialization
- New subsystem (authentication, real-time sync, etc.)
- Decisions that change how future features get built

**Action**: Write a design document.

## Step 2: Decision Maturity (Level 2 Only)

문서 안의 모든 결정을 **확정**과 **후보**로 구분할 것.

- **확정 결정**: 현재 마일스톤에서 구현할 것. 근거가 검증된 현재 제약에 기반. → "because" 근거 포함
- **후보 항목**: 나중에 필요할 수 있는 것. 아직 그 고통을 경험하지 않음. → 근거 없이 불릿 리스트로만 표기

### 구분 기준

각 결정에 대해 물어볼 것: **"이 결정의 근거가 지금 검증된 제약인가, 아직 경험하지 않은 추측인가?"**

- 근거가 현재 사실이면 → 확정 결정 (예: "2인 팀이므로" — 지금 사실)
- 근거가 미래 가정이면 → 후보 항목 (예: "외부 사용자가 필요하므로" — 아직 없음)

### 후보 항목 작성 패턴

후보 항목은 문서 하단에 별도 섹션으로 모을 것:

```
## v0 이후 검토 방향 (확정 아님 — v0 사용 경험 후 결정)

- 채팅 히스토리 DB 저장/복원
- Health sweep (자가 진단)
- Google OAuth
```

**금지**: 후보 항목에 "because" 근거를 달지 말 것. 근거를 달면 확정된 결정처럼 보인다.

## Step 3: Domain Decision Checklist (Level 2 Only)

Before writing the design document, load the relevant domain checklist to ensure no critical decisions are missed. The checklist asks "have you decided about X?" — it does NOT prescribe what to decide.

Available domain checklists:
- **`references/domain-web-service.md`** — Web service / API / real-time app
- Add more domain files as needed

If no domain checklist exists for the project type, identify decision categories by asking:
1. How does data flow between components?
2. What are the external dependencies?
3. What must this system NOT do?

## Step 4: Apply the 5 Principles

When writing a Level 2 design document, follow these principles strictly. Read `references/principles.md` before writing a Level 2 design document for the first time.

1. **Decisions Only** — Record what was decided and why. Not implementation.
2. **Why, Not How** — AI generates implementation from decisions. Specifying "how" creates constraints and cascading consistency issues.
3. **Context Window Budget** — The design is AI's system prompt. Core design must fit ~200-300 lines. Details go in separate reference files.
4. **Decision Maturity** — 확정 결정은 근거 포함, 후보 항목은 근거 없이 목록만. (Step 2 참조)
5. **Constraints Over Prescriptions** — Tell AI what NOT to do. Leave the rest to AI's judgment.

## Step 5: Write the Design Document

기존 설계 문서가 있으면 해당 문서를 업데이트한다. 새 영역이면 프로젝트의 설계 문서 디렉토리에 새 파일을 생성한다. 저장 경로는 프로젝트의 기존 구조를 따를 것 (예: `docs/features/`, `docs/design/` 등). 유저에게 확인 후 진행.

```markdown
# [Feature/Milestone Name]

## Goal
One sentence describing what this milestone delivers.

## Tech Stack
- [Component]: [technology] — because [why]
- [Component]: [technology] — because [why]

## Architectural Decisions
- **[Decision]**: [what] — because [why]
- **[Decision]**: [what] — because [why]

## Constraints
- Must: [hard requirement]
- Must not: [prohibited approach]

## Scope
**In scope**: [what this version delivers]
**Out of scope**: [explicitly deferred to future milestones]

## Open Questions
Decisions deferred to future milestones.
```

**What NOT to include:**
- Function signatures or interfaces
- Pseudocode or implementation details
- Error handling for every edge case
- Database schemas with exact column types
- API response formats

These are implementation decisions. AI makes them during coding, guided by the architectural decisions and constraints above.

## Step 6: Validate

Before moving to implementation, check:

- [ ] Can the design fit as a section in CLAUDE.md? (~200-300 lines)
- [ ] Does every sentence describe a DECISION or CONSTRAINT, not an implementation?
- [ ] 확정 결정에만 "because" 근거가 있는가? 후보 항목에 근거가 달려있지 않은가?
- [ ] Would removing any section make implementation ambiguous? (If not, remove it)
- [ ] 후보 항목이 별도 섹션("v0 이후 검토 방향")으로 분리되어 있는가?

If any check fails, the design is over-specified. Trim it.

## Step 7: Update CLAUDE.md

CLAUDE.md is the project's **system prompt** — loaded into every conversation. It is a concise work instruction manual (~500 lines max) covering: project overview, tech stack, coding guidelines, workflow, folder structure, rules.

CLAUDE.md는 작업 지침서이지 설계 문서가 아니다. 설계 내용(아키텍처, 상태 머신, 도구 목록 등)은 설계 문서에만 둔다.

**CLAUDE.md에 들어갈 것:**
- 설계 문서 링크 + 각 문서의 참조 시점 (테이블 형태)
- 기술 스택 (무엇을 쓸지)
- 구현 규칙/금지 사항 (1줄 팩트)
- 디렉토리 구조 (새 폴더가 추가된 경우)

**CLAUDE.md에 들어가지 말아야 할 것:**
- 아키텍처 다이어그램, 상태 머신, 도구 목록 (→ 설계 문서)
- 근거, 대안, 트레이드오프 ("because...")
- 설계 문서 내용을 그대로 복제

**예시:**
```
## 설계 문서
설계 결정은 docs/features/에 있다. 구현 시 해당 영역의 문서를 먼저 읽고 결정 사항을 따를 것.

| 문서 | 참조 시점 |
|------|----------|
| web-service-architecture.md | 전체 구조, 상태 머신, 제약 조건 확인 시 |
```

## Workflow Summary

```
Requirement received
  → 대상 문서 확인 (유저 미지정 시 재질문)
  → Changes within existing code? → Level 0: Implement directly
  → Extends existing architecture? → Level 1: Constraints in prompt
  → New structural decisions? → Level 2:
      1. 확정/후보 구분 (Decision Maturity)
      2. Load domain checklist → identify decisions needed
      3. Apply 5 principles → write design document
      4. Validate: fits in context, decisions-only, maturity separated
      5. Get user approval
      6. Reflect into CLAUDE.md (링크 + 규칙만)
      7. Proceed to implementation
```

## Common Mistakes

Before proceeding to implementation, review the checklist below. If the design has gone through more than 2 review rounds, read `references/anti-patterns.md` for root-cause analysis.

**Quick checklist of what to avoid:**
- Writing pseudocode and calling it "design"
- 후보 항목에 "because" 근거를 달아 확정 결정처럼 보이게 하기
- Specifying function signatures before writing code
- Adding error handling to the design (AI handles this during implementation)
- 유저가 지정하지 않은 다른 문서를 참조해서 스코프를 판단하기
- CLAUDE.md에 설계 내용(아키텍처, 상태 머신)을 복제하기

## Additional Resources

### Reference Files

- **`references/principles.md`** — Detailed explanation of the 5 design principles (including Decision Maturity) with extended examples and rationale
- **`references/anti-patterns.md`** — Over-specification failure modes derived from real 16-round design review experience
- **`references/domain-web-service.md`** — Decision checklist for web service projects
