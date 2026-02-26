<div align="center">

# fablers-claude-harness

**프롬프팅을 그만두고, 하네스를 장착하세요.**

검증된 설계 방법론을 재사용 가능한 스킬로 인코딩한 Claude Code 플러그인.
즉흥적인 프롬프팅 대신, 실제로 작동하는 구조화된 워크플로우.

[![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.2.6-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## 왜 만들었나?

AI 코딩은 강력하지만, 구조 없이 쓰면 혼돈입니다:
- 과잉 설계 — 아무도 안 읽는 8,000줄짜리 설계 문서
- 과소 설계 — 쓰레기가 나오는 구현
- 매 세션마다 같은 워크플로우를 처음부터 다시 만듦

**fablers-claude-harness**는 검증된 방법론을 스킬로 패키징해서, Claude가 필요할 때 로드합니다.

---

## 스킬

### `vibe-design` — 딱 필요한 만큼만 설계

> *"설계 = 결정 + 제약 + 마일스톤. 절대 의사코드 아님."*

바이브 코딩에 최적화된 수준의 설계 문서를 만들어줍니다. 8,000줄짜리 설계 문서는 이제 끝.

| 단계 | 하는 일 |
|------|--------|
| 스코프 체크 | 설계 문서가 필요한가? 불필요하면 바로 구현. |
| 사용자 대화 | 질문 하나씩. 열린 질문보다 선택지 우선. |
| 결정 성숙도 | 확정 결정에만 근거. 후보는 불릿 리스트만. |
| 도메인 체크리스트 | 빠진 결정 없이 꼼꼼하게. |
| 작성 & 검증 | ~200-300줄. 모든 줄이 결정이지, 구현이 아님. |

```
> 설계해줘
> 아키텍처 잡아줘
> design a feature
```

---

### `design-review` — 6축 평가, S~F 등급

> *"의사코드가 있으면 설계 문서가 아니다."*

실제 과잉 설계 실패 사례에서 도출한 6개 축으로 설계 문서를 평가합니다. 등급, 점수, 구체적 수정 방법을 출력.

```
Grade: A | Score: 83

┌─────────────────────┬───────┬────────┐
│ Axis                │ Grade │ Points │
├─────────────────────┼───────┼────────┤
│ Decision Purity     │ PASS  │   2    │
│ Rationale Presence  │ PASS  │   2    │
│ Decision Maturity   │ WARN  │   1    │
│ Context Budget      │ PASS  │   2    │
│ Constraint Quality  │ PASS  │   2    │
│ CLAUDE.md Alignment │ WARN  │   1    │
└─────────────────────┴───────┴────────┘
```

**FAIL**이 하나라도 있으면 등급이 C로 제한. 근본적인 문제가 있는 설계는 통과 불가.

```
> 설계 리뷰해줘
> 이 설계 괜찮아?
> review my design
```

---

### `session-skill-extractor` — 대화를 스킬로 변환

> *"최고의 워크플로우가 세션과 함께 사라져선 안 된다."*

현재 대화를 분석해서 보존할 가치가 있는 패턴을 찾고, 승인하면 스킬로 만들어줍니다.

**작동 방식:**

1. 전체 대화를 6가지 신호 유형으로 스캔
2. 재사용성, 복잡도, 고유성으로 후보 점수 매기기
3. 제안 제시 — 사용자가 선택
4. 적절한 구조, 트리거 문구, 참조 파일과 함께 스킬 생성
5. 완료 전 구조 검증

복잡도가 낮은 패턴은 스킬 대신 CLAUDE.md 규칙으로 리다이렉트. 스킬 비대화 방지.

```
> 대화에서 스킬 추출해줘
> 이 세션에서 스킬 만들 게 있어?
> extract skill from conversation
```

---

## 빠른 시작

```bash
# 마켓플레이스 등록
/plugin marketplace add flashwade03/fablers-claude-plugins

# 플러그인 설치
/plugin install fablers-claude-harness@fablers
```

로컬 개발 시:

```bash
claude --plugin-dir /path/to/fablers-claude-harness
```

---

## 프로젝트 구조

```
fablers-claude-harness/
├── .claude-plugin/
│   ├── plugin.json              # 플러그인 매니페스트
│   └── marketplace.json         # 마켓플레이스 메타데이터
└── skills/
    ├── vibe-design/             # 설계 방법론
    │   ├── SKILL.md
    │   └── references/
    │       ├── principles.md
    │       ├── anti-patterns.md
    │       └── domain-web-service.md
    ├── design-review/           # 6축 리뷰 스코어링
    │   ├── SKILL.md
    │   ├── references/
    │   └── examples/
    └── session-skill-extractor/ # 대화 → 스킬 변환
        ├── SKILL.md
        └── references/
            ├── analysis-criteria.md
            └── transformation-guide.md
```

---

## 철학

이 플러그인은 세 가지 원칙을 따릅니다:

1. **결정이지, 구현이 아니다** — 설계 문서는 *무엇*과 *왜*를 기록한다. *어떻게*는 절대 아님
2. **점진적 공개** — 핵심 워크플로우가 먼저 로드되고, 상세 내용은 필요할 때만
3. **복잡도는 벌어야 한다** — 단순한 패턴은 단순하게. 스킬은 충분히 복잡할 때만 생성

---

## 라이선스

MIT
