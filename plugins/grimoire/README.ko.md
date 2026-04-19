<div align="center">

# grimoire

**재사용 가능한 Claude Code 스킬의 책.**

단일 목적 플러그인이 아닙니다. 특정 커맨드·워크플로우에 묶이지 않는 범용 스킬의 성장하는 모음집 — 어떤 플러그인이 켜져 있든 상황에 따라 Claude가 알아서 꺼내 쓰는 종류의 패턴들.

`grimoire`는 "재사용 패턴의 책"이라는 메타포입니다. 지금 읽고 계신 이 README가 그 메타포의 불친절함을 보완합니다.

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](../../LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## 스킬

| 스킬 | 하는 일 |
|------|--------|
| **agent-teams** | 단일 에이전트가 여러 페르소나를 연기하는 "가짜 팀" 대신, 진짜 Claude Code agent team (TeamCreate + SendMessage)을 띄워 debate / review / implementation 수행. cross-challenge 프롬프트 패턴, worked example, `/forge-team`과의 경계 명시 포함. |

재사용 패턴이 축적될 때마다 스킬이 추가됩니다.

---

## 스킬 발동 방식

grimoire의 스킬은 슬래시 커맨드가 아니라 자연어 의도로 활성화됩니다:

```
> 에이전트 팀 만들어줘               # agent-teams 스킬 발동
> debate with agent teams          # 동일 — 구조화된 cross-agent debate
> 3명 에이전트로 X 리뷰해줘          # 동일
```

각 스킬은 자신의 `description` frontmatter에 트리거 키워드를 가지고 있고, Claude가 사용자 표현에 맞춰 적절한 스킬을 선택합니다.

---

## 설치

```bash
/plugin marketplace add flashwade03/fablers-claude-plugins
/plugin install grimoire@fablers
```

별도 설정 파일은 필요 없습니다. 스킬은 필요할 때 로드됩니다.

### 전제 조건

`agent-teams`는 Claude Code의 실험적 agent-teams 플래그가 필요합니다:

```json
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## 프로젝트 구조

```
grimoire/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── agent-teams/
        └── SKILL.md
```

---

## 이 이름인 이유

`damascus`, `sketch`, `forge`는 이 마켓플레이스의 기존 메타포 계열 브랜드 이름입니다. `grimoire`는 그 가족에 들어맞는 이름 — 패턴이 담긴 책, 늘 선반 위에 있고 필요할 때 꺼내 씁니다. `common-skills`, `reusable-patterns` 같은 직설적 이름도 후보였지만, 자매 플러그인과의 네이밍 일관성을 고려해 `grimoire`로 결정됐습니다.

대가는: 메타포 이름은 설명 문장이 있어야 쓸모가 있다는 것. 이 페이지가 그 역할을 합니다.

---

## 라이선스

MIT
