---
name: vibe-design
description: This skill should be used when the user explicitly asks to "design a feature", "create architecture", "plan a system", "how much design do I need?", "should I write a spec?", "is this over-engineered?", "설계해줘", "아키텍처 잡아줘", "설계 범위 정해줘", "기획 문서 써야 할까?". This skill must be explicitly invoked — do NOT trigger automatically before plan mode or implementation. Guides design scope to produce exactly the right amount of specification, preventing over-specification that kills vibe coding productivity.
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

## Step 1: Scope Check

이 요구사항이 설계 문서가 필요한 수준인지 판단한다.

**설계 불필요 (바로 구현):**
- 기존 코드 구조 안에서 완결되는 작업 (버그 수정, 설정 변경, 패턴 확장)
- 새로운 구조적 결정이 없는 경우

**설계 필요 (이 스킬 계속 진행):**
- 새로운 구조적 결정이 필요하고, 이후 기능이 이 결정에 의존하는 경우
- 새 프로젝트, 새 서브시스템, 아키텍처 변경 등

설계 불필요로 판단되면 사용자에게 알리고 스킬을 종료한다.

## Step 1.5: User Dialogue

설계 문서를 작성하기 전에 사용자와 대화를 통해 핵심 결정을 구체화한다.

### 왜 필요한가

설계 문서의 결정은 두 종류다:
- **AI가 판단해도 되는 결정** (라이브러리 선택, 파일 구조, 내부 구현)
- **사용자만 답할 수 있는 결정** (UX 흐름, 비즈니스 규칙, 우선순위, 톤)

후자를 AI가 추측하면 구현이 불안정해진다. 대화로 확정해야 한다.

### 대화 규칙

- **1문 1답**: 한 메시지에 질문 하나만. 여러 질문을 한꺼번에 던지지 말 것.
- **선택지 우선**: 가능하면 2-4개 선택지를 제시. 열린 질문보다 선택이 빠르다.
- **접근 방식 제안**: 핵심 구조 결정 시 2-3개 접근 방식을 트레이드오프와 함께 제시하고 선택받을 것.
- **사용자 응답이 선택지 밖이면 따를 것**: 사용자가 선택지 외 답변을 하면 그것이 결정이다.

### 무엇을 물어볼 것인가

프로젝트 도메인에 따라 다르다. 핵심 기준: **"이 결정을 AI가 추측했을 때, 사용자가 '아닌데?'라고 할 가능성이 있는가?"** 가능성이 있으면 물어볼 것.

예시 (도메인별):
- 프론트엔드: 화면 구성, 네비게이션 흐름, 인터랙션 패턴, 디자인 톤
- 백엔드: 데이터 모델 경계, 외부 서비스 연동 방식, 인증 전략
- CLI: 명령 구조, 출력 형식, 에러 처리 수준
- 에이전트: 역할 분담, 자율성 수준, 사람 개입 지점

### 대화 종료 기준

다음 조건을 모두 만족하면 대화를 종료하고 다음 단계로:
- Domain checklist(Step 3)의 v0 항목에 해당하는 결정이 모두 확정됨
- 사용자가 "아닌데?"라고 할 만한 추측이 남아있지 않음

### 대화 결과의 시각화

대화에서 확정된 결정 중 **흐름이 있는 결정**은 텍스트만으로 전달이 어렵다. 다음에 해당하면 설계 문서에 Mermaid 다이어그램을 포함할 것:

- **여러 주체 간 요청/응답 흐름** (에이전트 위임, API 호출 체인) → 시퀀스 다이어그램
- **상태 전이가 있는 시스템** (Job 상태, 세션 라이프사이클) → 상태 다이어그램
- **데이터가 여러 단계를 거치는 처리 과정** (파이프라인, 워크플로우) → 플로우차트

**이것은 구현 디테일이 아니라 결정의 시각적 표현이다.** "Orchestrator가 Translator에게 위임한다"는 텍스트 결정이고, 그 위임의 순서와 데이터 흐름을 시퀀스 다이어그램으로 그리는 것은 같은 결정을 더 명확하게 전달하는 것이다.

**포함하지 말 것:** 함수 호출 그래프, 클래스 다이어그램, ERD — 이것들은 구현 시 AI가 결정할 것.

## Step 2: Decision Maturity

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

## Step 3: Domain Decision Checklist

Before writing the design document, load the relevant domain checklist to ensure no critical decisions are missed. The checklist asks "have you decided about X?" — it does NOT prescribe what to decide.

Available domain checklists:
- **`references/domain-web-service.md`** — Web service / API / real-time app
- Add more domain files as needed

If no domain checklist exists for the project type, identify decision categories by asking:
1. How does data flow between components?
2. What are the external dependencies?
3. What must this system NOT do?

## Step 4: Apply the 5 Principles

설계 문서 작성 시 아래 원칙을 엄격히 따를 것. 처음 설계 문서를 작성하기 전에 `references/principles.md`를 읽을 것.

1. **Decisions Only** — Record what was decided and why. Not implementation.
2. **Why, Not How** — AI generates implementation from decisions. Specifying "how" creates constraints and cascading consistency issues.
3. **Context Window Budget** — The design is AI's system prompt. Core design must fit ~200-300 lines. Details go in separate reference files.
4. **Decision Maturity** — 확정 결정은 근거 포함, 후보 항목은 근거 없이 목록만. (Step 2 참조)
5. **Constraints Over Prescriptions** — Tell AI what NOT to do. Leave the rest to AI's judgment.

## Step 4.5: Decision-Document Mapping (복수 문서 업데이트 시)

대상 문서가 2개 이상일 때, 작성 전에 각 결정이 어느 문서의 스코프에 해당하는지 매핑한다.

- 하나의 결정이 여러 문서에 해당할 수 있다 — 중복이 아니라 각 문서의 추상화 수준에 맞는 표현이 들어가야 한다.
- 매핑 테이블을 작성하여 누락을 방지할 것:

| 결정 | 해당 문서 | 표현 수준 |
|------|----------|----------|
| [결정 내용] | [문서명] | [이 문서에서의 추상화 수준] |

- 매핑 기준: **"이 결정이 이 문서의 스코프(제목, 첫 문장)에 해당하는가?"**
- 대상 문서가 1개이면 이 단계를 건너뛴다.

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

### 도메인별 결정 섹션

위 기본 템플릿(Goal, Tech Stack, Architectural Decisions, Constraints, Scope) 외에, Step 1.5 대화에서 나온 도메인 특화 결정을 별도 섹션으로 추가한다.

**섹션 이름과 내용은 도메인에 맞게 유연하게 결정한다.** 예시:

- 프론트엔드 → `## Screens`: 화면별 핵심 구성 요소와 인터랙션 결정
- 백엔드 API → `## Endpoints`: 핵심 엔드포인트와 데이터 흐름 결정
- CLI → `## Commands`: 명령 구조와 입출력 형태 결정
- 에이전트 → `## Agent Roles`: 에이전트별 역할과 도구 경계 결정

**작성 기준**: "이 내용이 없으면 AI가 잘못 구현할 가능성이 높은가?" Yes면 포함. No면 AI 판단에 맡긴다.

**금지**: 이 섹션에서도 구현 디테일(컴포넌트 트리, 라우트 테이블, API 시그니처)은 기본적으로 적지 않는다. 결정과 핵심 요소만 기술한다 — 단, 사용자가 대화에서 명시적으로 결정한 것이 그 수준이라면 포함한다.

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
  → Scope Check: 설계 불필요 → 스킬 종료, 바로 구현
  → 설계 필요 →
      1. 사용자 대화로 핵심 결정 구체화 (Step 1.5)
      2. 확정/후보 구분 (Decision Maturity)
      3. Load domain checklist → identify decisions needed
      4. Apply 5 principles
      4.5. 복수 문서 시 결정-문서 매핑 (누락 방지)
      5. Write design document (기본 템플릿 + 도메인별 결정 섹션)
      6. Validate: fits in context, decisions-only, maturity separated
      7. Get user approval
      8. Reflect into CLAUDE.md (링크 + 규칙만)
      9. Proceed to implementation
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
- 복수 문서 업데이트 시 결정-문서 매핑 없이 바로 작성하여 스코프에 해당하는 결정을 누락하기
- 사용자 대화(Step 1.5) 없이 AI가 도메인 결정을 추측해서 문서에 적기
- 사용자가 대화에서 명시적으로 결정한 것을 "구현 디테일"이라며 문서에서 제외하기

## Additional Resources

### Reference Files

- **`references/principles.md`** — Detailed explanation of the 5 design principles (including Decision Maturity) with extended examples and rationale
- **`references/anti-patterns.md`** — Over-specification failure modes derived from real 16-round design review experience
- **`references/domain-web-service.md`** — Decision checklist for web service projects
