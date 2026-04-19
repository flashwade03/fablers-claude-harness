<div align="center">

# fablers

**프롬프팅을 그만두고, 하네스를 장착하세요.**

검증된 워크플로우를 재사용 가능한 플러그인으로 패키징한 Claude Code 마켓플레이스.
설계 방법론, 문서 단조, 에이전틱 RAG — 한 곳에서.

[![Claude Code Marketplace](https://img.shields.io/badge/Claude_Code-Marketplace-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.10.0-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## 플러그인

### `vibe-architecture` — 설계 방법론 & 스킬 추출

검증된 설계 방법론을 스킬로 인코딩해서 Claude가 필요할 때 로드합니다. 즉흥적 프롬프팅 대신, 실제로 작동하는 구조화된 워크플로우.

| 스킬 | 하는 일 |
|------|--------|
| **vibe-design** | 러프한 아이디어를 딱 필요한 만큼의 설계로. 결정 + 제약 + 마일스톤, 절대 의사코드 아님. |
| **design-review** | 6축 평가로 설계 문서 점수 매기기 (S~F 등급, 0-100점). FAIL 1개면 등급 C 제한. |
| **sketch-team** | Agent Teams 워크플로우로 **구체적 멀티-도메인 설계**: Specialist Designer 1–3명 (data-model / api-surface / protocol 등, Lead가 task별 결정)이 기각된 대안 인라인 기록 포함 구체 artifact 생산, Planner가 cross-domain 일관성 체크 후 합성, Reviewer 2명이 구체화-친화 6축 rubric으로 판정, 승인까지 루프. |
| **session-skill-extractor** | 대화를 분석해서 재사용 가능한 패턴 추출. 스킬, CLAUDE.md, hookify, memory로 라우팅. |

```
> /sketch                          # 설계 시작 (단일 에이전트 Q&A)
> /sketch-team <작업>              # Agent Teams: 설계 + 리뷰 번들, 자동 이터레이션
> 설계 리뷰해줘                      # 설계 리뷰
> 대화에서 스킬 추출해줘              # 세션에서 스킬 추출
```

---

### `damascus` — 반복적 멀티-LLM 리뷰로 문서 단조

> *다마스커스 강철처럼, 문서는 반복된 단조를 통해 강해진다.*

여러 LLM을 활용한 반복 리뷰 루프로 문서를 정제합니다. 구현 계획이나 기술 문서를 작성하고, Claude, Gemini, OpenAI가 병렬로 리뷰한 뒤 승인될 때까지 반복.

```
> /forge <작업 설명>                # 단일 리뷰어 단조
> /forge-team <작업 설명>           # 멀티-LLM 팀 리뷰
> /forge-plan <작업 설명>           # 계획만
> /forge-doc <작업 설명>            # 문서만
```

---

### `fablers-agentic-rag` — 문서에 질문하세요. 인용된 답변을 받으세요.

에이전틱 RAG 파이프라인 — 쿼리 분석, 하이브리드 검색 (벡터 + BM25), CRAG 검증, 인용 답변 합성 — 모두 Claude 에이전트가 오케스트레이션. PDF, 텍스트, 마크다운 지원.

```
> /ingest <파일>                   # 문서 인덱싱
> /rag-ask <질문>                  # 인용 포함 질의
> /rag-search <쿼리>               # 원시 검색
```

---

### `grimoire` — 범용 재사용 스킬 모음집

단일 목적 플러그인이 아님. 특정 커맨드·워크플로우에 묶이지 않는 Claude Code 스킬 모음 — 어떤 플러그인이 켜져 있든 상황에 따라 Claude가 알아서 꺼내 쓰는 패턴들입니다. `grimoire`라는 이름은 "재사용 가능한 패턴의 책"이라는 메타포이며, 지금 읽고 계신 이 설명이 그 메타포의 불친절함을 보완합니다.

| 스킬 | 하는 일 |
|------|--------|
| **agent-teams** | 단일 에이전트가 여러 페르소나를 연기하는 "가짜 팀" 대신, 진짜 Claude Code agent team (TeamCreate + SendMessage)을 띄워 debate / review / implementation 수행. cross-challenge 프롬프트 패턴, worked example, `/forge-team`과의 경계 명시 포함. |

```
> 에이전트 팀 만들어줘               # 진짜 에이전트 팀 스폰
> 팀으로 토론해줘                   # 구조화된 cross-agent debate
```

---

## 빠른 시작

```bash
# 마켓플레이스 등록
/plugin marketplace add flashwade03/fablers-claude-plugins

# 개별 플러그인 설치
/plugin install vibe-architecture@fablers
/plugin install damascus@fablers
/plugin install fablers-agentic-rag@fablers
/plugin install grimoire@fablers
```

---

## 프로젝트 구조

```
my-claude-harness/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── vibe-architecture/         # 설계 방법론
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/
│   │   └── skills/
│   │       ├── vibe-design/
│   │       ├── design-review/
│   │       └── session-skill-extractor/
│   ├── damascus/                       # 문서 단조
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   ├── commands/
│   │   ├── hooks/
│   │   ├── scripts/
│   │   └── skills/
│   ├── fablers-agentic-rag/            # 에이전틱 RAG
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   ├── commands/
│   │   ├── hooks/
│   │   ├── scripts/
│   │   └── skills/
│   └── grimoire/                       # 범용 재사용 스킬 모음집
│       ├── .claude-plugin/plugin.json
│       └── skills/
│           └── agent-teams/
```

---

## 철학

1. **결정이지, 구현이 아니다** — 설계 문서는 *무엇*과 *왜*를 기록한다. *어떻게*는 절대 아님
2. **점진적 공개** — 핵심 워크플로우가 먼저 로드되고, 상세 내용은 필요할 때만
3. **복잡도는 벌어야 한다** — 단순한 패턴은 단순하게. 스킬은 충분히 복잡할 때만 생성

---

## 라이선스

MIT
