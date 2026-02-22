# 5 Design Principles for Vibe Coding

## Principle 1: Decisions Only

Record WHAT was decided and WHY. Never HOW to implement it.

### Good Examples

```
- State machine: waiting → creating → playable ↔ modifying.
  Error state is only reachable from creating.
  Reason: modifying always has a fallback (previous working version).

- 2-layer architecture: Service Agent (conversation) ↔ Claude Code (coding).
  Reason: separates cheap/fast intent parsing from expensive/slow code generation.

- Ports allocated dynamically from range 5173-5199.
  Reason: multiple projects run simultaneously, static ports would conflict.
```

### Bad Examples (Implementation Masquerading as Design)

```
// This is CODE, not design:
const VALID_TRANSITIONS = {
  waiting: ['creating'],
  creating: ['playable', 'error', 'waiting'],
  playable: ['modifying', 'creating'],
  modifying: ['playable'],
  error: ['creating', 'waiting'],
};

function validateTransition(from, to) {
  if (!VALID_TRANSITIONS[from]?.includes(to)) {
    throw new Error(`Invalid transition: ${from} → ${to}`);
  }
}
```

The state machine decision (what states exist, what transitions are valid) is design.
The validation function is implementation. AI writes this from the decision.

### 예외: 사용자가 대화에서 명시적으로 확정한 결정

사용자가 Step 1.5 대화에서 구현 수준의 선택을 명시적으로 결정한 경우, 그것은 설계 결정으로 취급한다. 예: 사용자가 "WebSocket을 써라"가 아니라 대화에서 실시간 통신 방식을 물었을 때 "WebSocket"을 선택한 경우 — 이것은 사용자의 결정이므로 기록한다.

AI가 추측한 구현 디테일은 여전히 금지. 사용자가 결정한 것만 예외.

### Test

For every line in the design document, ask: "Is this a decision, or is this telling the AI how to write code?" If the latter — and it was NOT explicitly decided by the user in dialogue — delete it.

---

## Principle 2: Why, Not How

The "why" enables AI to make correct implementation decisions in cases the design didn't anticipate. The "how" constrains AI to a single implementation path that may not be optimal.

### Good Examples

```
- Dev server managed by service layer, not by Claude Code.
  Why: Claude Code runs in isolated subprocess with no access to shared port state.

- WebSocket for client-server communication, not REST polling.
  Why: real-time streaming of Claude Code output to browser.

- Boilerplate copied per project, not shared.
  Why: Claude Code modifies files in place; shared boilerplate would cause cross-contamination.
```

### Bad Examples

```
- Use Express middleware with http-proxy to forward requests to Vite dev servers.
  Register proxy with registerProxy(projectId, port) and unregister with unregisterProxy(projectId).
  Store in proxies Map<string, HttpProxy>.

- Use allocatePort() that checks reservedPorts Set, tries net.createServer().listen(),
  and returns the first available port. Call releasePortReservation() after DB commit.
```

These specify the exact implementation mechanism. An AI reading the "why" (dynamic port allocation for concurrent projects) would arrive at an equivalent or better implementation on its own.

### 예외: 사용자가 대화에서 명시적으로 확정한 결정

Principle 1과 동일한 예외가 적용된다. 사용자가 Step 1.5 대화에서 특정 기술/방식을 선택한 경우, 그것은 "how"가 아니라 사용자의 결정이다. 예: 사용자가 "HTTP polling vs WebSocket?" 질문에 "WebSocket"을 선택 → "WebSocket for client-server communication — because 사용자 결정: 실시간 스트리밍 필요"로 기록.

AI가 자체적으로 기술 선택을 확정하여 적는 것은 여전히 금지.

### The Cascading Consistency Problem

When "how" is specified in design, every detail must be consistent with every other detail. In a real case study, specifying function signatures and resource management patterns in design documents led to 115 cross-reference bugs across 16 review rounds. These bugs would not have existed if only decisions were specified.

---

## Principle 3: Context Window Budget

In vibe coding, the design document is part of AI's working context. Every line of design competes with code, conversation history, and tool output for context space.

### Budget Guidelines

| Content | Budget | Location |
|---------|--------|----------|
| Core architecture decisions | ~200-300 lines | CLAUDE.md or inline |
| Constraint list | ~20-50 lines | Same document |
| Milestone scope | ~10-20 lines | Same document |
| Detailed reference (if needed) | Unlimited | Separate file, loaded on demand |

### Practical Test

If the design document, when prepended to a coding prompt, would push the conversation past 50% of context window before any code is written — it's too long.

### What This Means

A system with 7 tools, 5 state transitions, 6 shared data structures, dynamic port allocation, proxy management, health monitoring, crash recovery, and graceful shutdown — all of this can be described in ~200 lines of decisions and constraints. The 4,500-line version with pseudocode is 20x over budget.

---

## Principle 4: Decision Maturity

문서 안의 모든 항목을 **확정 결정**과 **후보 항목**으로 구분한다. 구분 기준은 근거의 검증 여부.

### 구분 기준

각 결정에 대해 물어볼 것: **"이 결정의 근거가 지금 검증된 제약인가, 아직 경험하지 않은 추측인가?"**

- **확정 결정**: 근거가 현재 사실에 기반 → "because" 근거 포함
- **후보 항목**: 근거가 미래 가정에 기반 → 근거 없이 목록만 표기

### Good Examples

```
## 인증 (확정)
- JWT 24시간 만료, 리프레시 토큰 없음 — because 2인 팀이므로 복잡한 인증 불필요
- SQLite에 하드코딩 유저 2명 — because 회원가입 시스템은 현재 불필요

## v0 이후 검토 방향 (확정 아님 — v0 사용 경험 후 결정)
- Google OAuth
- Health sweep (자가 진단)
- 로그 로테이션
```

확정 결정에는 근거가 있고, 후보 항목에는 근거가 없다. 후보의 근거는 경험 후에 생긴다.

### Bad Examples

```
## v1: 운영 안정성
- Health sweep (5분 주기) — because 프로세스 크래시/포트 점유 시 자동 감지 필요
- 로그 로테이션 — because 장기 운영 시 로그 파일 무한 증가 방지
```

아직 운영해보지 않았으므로 "프로세스 크래시"와 "장기 운영"은 추측이다. "because"를 달면 확정된 결정처럼 보여서 과잉 설계를 유발한다.

### The Maturity Test

For each "because" in the document, ask: "Have I actually experienced this problem, or am I guessing?"

- Experienced → keep the rationale (확정)
- Guessing → strip the rationale, move to candidates section (후보)

---

## Principle 5: Constraints Over Prescriptions

Constraints define the boundary. Everything inside the boundary is AI's decision space.

### Effective Constraints

```
- Claude Code must NOT start dev servers (service layer manages ports)
- State transitions must go through a validation function (no direct DB updates)
- One Claude Code process per project at a time (no concurrent modifications)
- Boilerplate directory is read-only (always copy, never modify in place)
- Dev server ports must be released when project is deleted
```

### Ineffective Prescriptions (Disguised as Constraints)

```
- Must use http-proxy library for proxying  → This is a library choice, not a constraint
- Must store ports in SQLite with column type INTEGER  → This is a schema detail
- Must use Map<string, ChildProcess> for process tracking  → This is a data structure choice
- Must call releasePortReservation() in finally block  → This is an implementation pattern
```

### Why Constraints Work Better

AI operating within constraints exercises judgment. AI following prescriptions exercises compliance. When something unexpected happens during implementation (a library doesn't work, a pattern doesn't fit), constraint-guided AI adapts. Prescription-following AI either breaks the prescription or gets stuck.
