<div align="center">

# vibe-architecture

**결정을 먼저. 구현은 AI가.**

Vibe coding 설계 방법론을 Claude Code 스킬로 감싼 플러그인 — 러프한 아이디어를 구조화된 스펙(결정·제약·마일스톤, **의사코드는 절대 아님**)으로 전환하고, 6축 rubric으로 점수를 매기고, 추상 스펙만으로 부족한 경우 Agent Teams로 멀티-도메인 구체 설계까지 확장합니다. 세션에서 재사용 가능한 패턴을 스킬로 역추출하는 기능도 포함.

[![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.8.3-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](../../LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## 스킬

### vibe-design

러프한 아이디어를 딱 필요한 만큼의 설계 스펙으로. 아이디어 탐색부터 구조화된 설계 문서까지 전 과정을 커버.

- **Scope check**: 설계 문서가 정말 필요한가? 아니면 스킵하고 바로 구현.
- **1-question-at-a-time 대화**: 2-3개 접근안을 트레이드오프와 함께 제시.
- **Decision maturity**: 확정 결정에는 근거를, 후보는 bullet으로 남김.
- **Output**: 결정과 제약으로 이루어진 200-300줄, 의사코드는 없음.

```
> /sketch                 # 권장 — 항상 스킬 로드
> 설계해줘                  # 자연어 트리거는 일관되지 않을 수 있음
> 아키텍처 잡아줘
```

자연어 표현만으론 스킬이 안정적으로 발동하지 않습니다 — 광범위한 설계 대화는 Claude가 직접 처리하는 경우가 많아요. 방법론을 명시적으로 로드하려면 `/sketch`를 쓰세요.

### design-review

설계 문서를 6축 vibe coding rubric으로 채점. Grade (S~F), Score (0-100), 구체적 피드백을 출력.

| 축 | 검사 내용 |
|-----|----------|
| Decision Purity | 모든 문장이 결정이며 구현이 아님 |
| Rationale Presence | 모든 결정에 근거 명시 |
| Decision Maturity | 확정 vs 후보 결정이 명확히 구분 |
| Context Budget | 200-300줄 내 수렴 |
| Constraint Quality | 경계이지 처방이 아님 |
| CLAUDE.md Alignment | 설계 문서가 링크되어 있고 중복되지 않음 |

어떤 축이든 FAIL 1개면 등급 C로 제한.

```
> 설계 리뷰해줘
> score this design
> design quality check
```

### sketch-team

Agent Teams로 **구체적 멀티-도메인 설계** 생산. `/sketch` (vibe-design 단독)가 AI가 나중에 채울 수 있도록 결정을 추상으로 두는 반면, `/sketch-team`은 의도적으로 구체화합니다 — 인터페이스, 데이터 형태, 시퀀스 다이어그램. 어떤 도메인에서는 구체적 artifact *자체*가 결정이기 때문입니다 (API 계약, 메시지 프로토콜, 캐스케이딩 타입을 가진 데이터 모델 등).

Lead가 사용자 대화를 관리 (vibe-design Step 0.5–1.5), task의 자연스러운 도메인 분해에 따라 1–3명의 **Specialist Designer**를 선택 (예: `data-model`, `api-surface`, `protocol`), 그 후 팀이 자율적으로 실행:

- **Specialist 구성은 task별 Lead 결정**: 같은 문제의 "접근법"들이 아니라 — 각 Designer는 팀의 한 도메인 전문가
- **2-pass 정합성**: 예비 도메인 artifact → Planner가 peer 요약 + cross-domain 충돌 식별 → 정제된 artifact → 합성. Specialist가 고려한 기각 대안은 `Alternative considered: X — rejected because Y` 형태로 인라인에 남음.
- **단일 writer (Scribe)**: design.md와 .review.md — 역할 경계 명확, 파일 충돌 없음
- **구체화-친화 7축 rubric**: Specification Productivity / Rationale Presence / Decision Maturity / Failure Coverage / Specialist Coherence / Constraint Quality / CLAUDE.md Alignment. load-bearing 구체 artifact (시그니처, 스키마, 시퀀스 다이어그램)는 허용하되 장식용 의사코드는 거부. Failure Coverage는 critical failure mode들이 처리 결정과 함께 명시되었는지 체크.
- **엄격한 판정 + max_rounds 상한**: 어떤 축이든 FAIL → NEEDS_REVISION; 기본 상한 3; 도달 시 사용자에게 escalate

**전제 조건**: `.claude/settings.json`에 다음 필요:
```json
{
  "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" },
  "teammateMode": "tmux"
}
```
`teammateMode: "tmux"`는 선택이지만 권장 — 팀원별 split pane이 열려 작업을 관찰 가능.

```
> /sketch-team 재시도와 우선순위를 처리하는 작업 큐 설계해줘
> /sketch-team -n 5 멀티 테넌트 데이터 격리 아키텍처
> /sketch-team -o docs/features/notifications.md 알림 시스템 설계
```

**언제 뭘 쓸지**: 구현을 열어두는 게 옳은 초기 단계에는 `/sketch`. 구체화 자체가 결정을 짓는 설계 (API 계약, 메시지 프로토콜, 멀티-도메인 데이터 형태)에는 `/sketch-team`.

### session-skill-extractor

현재 대화를 분석해서 재사용 가능한 패턴을 추출. 각 발견을 최적의 목적지로 라우팅:

- **반복 가능한 워크플로우** → 새 스킬
- **명시적 규칙** → CLAUDE.md
- **수정 사항** → hookify 규칙
- **도메인 지식** → memory

```
> 대화에서 스킬 추출해줘
> 세션 회고
> turn this conversation into skills
```

## 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/sketch` | vibe-design 대화식 시작 (단일 에이전트 Q&A) |
| `/sketch-team` | Agent Teams 워크플로우 — 설계 + 리뷰 번들, 승인 또는 max_rounds까지 자동 이터레이션 |
