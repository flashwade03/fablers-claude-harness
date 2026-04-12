---
name: session-skill-extractor
description: Extract reusable skills, rules, and knowledge from current conversation. ALWAYS consult this skill when user says: "세션 회고", "대화 분석", "스킬 추출", "배운 거 정리", session review, turn conversation into skills, capture patterns, 교정한 거 정리.
---

# Session Skill Extractor

## Purpose

Analyze the current session's conversation to discover patterns, corrections, rules, and domain knowledge worth preserving. Route each finding to the appropriate destination — not everything is a skill. Some findings are better as CLAUDE.md rules, hookify rules, or memory entries.

## When NOT to Use

- Session has fewer than ~10 back-and-forth exchanges — not enough signal
- Conversation was purely Q&A with no multi-step workflow, corrections, or domain knowledge transfer
- The identified pattern already exists as a skill, CLAUDE.md rule, or hookify rule in this plugin

## Step 0: Load Existing Context

Before analysis, scan existing outputs to establish a baseline and avoid duplicates.

1. Read all `skills/*/SKILL.md` files in this plugin
2. Read project CLAUDE.md files for existing rules
3. Check memory files for existing knowledge
4. Keep this inventory as a deduplication reference throughout the process

## Step 1: Conversation Analysis

Scan the current session conversation and classify findings using the 5 characteristic types. Read `references/analysis-criteria.md` for the detailed detection heuristics and decision tree.

### The 5 Characteristic Types

| Type | What to look for | Primary routing |
|------|-----------------|-----------------|
| **1. 유저 교정** | Claude가 틀려서 유저가 바로잡은 순간 | hookify / CLAUDE.md |
| **2. 반복 워크플로우** | 같은 절차가 2회 이상 실행 | skill |
| **3. 명시적 규칙 선언** | 유저가 "항상/절대" 류 규칙 선언 | CLAUDE.md |
| **4. 시행착오 해결** | Claude가 자체적으로 실패→성공 | skill Constraints / CLAUDE.md |
| **5. 도메인 지식 전달** | 코드로 알 수 없는 맥락 설명 | CLAUDE.md / memory |

### 판별 순서

유형 간 겹침을 방지하기 위해, `references/analysis-criteria.md`의 Decision Tree를 따른다.

### Analysis Scope

Analyze the ENTIRE conversation from the beginning, not just recent messages. Patterns often emerge from the cumulative flow rather than individual exchanges.

### What to Ignore

- One-off debugging or troubleshooting that won't recur
- Simple tool usage (file reads, edits) without a higher-level pattern
- Patterns already covered by existing outputs (from Step 0)
- Generic programming knowledge Claude already possesses

For each finding, record:
- **Pattern name**: Short descriptive label
- **Characteristic type**: Which of the 5 types
- **Evidence**: Specific conversation moments that demonstrate the pattern
- **Routing destination**: skill / CLAUDE.md / hookify / memory

## Step 2: Score and Prioritize

For each finding, evaluate against three criteria (see scoring matrix in `references/analysis-criteria.md`):

| Criterion | Question | Weight |
|-----------|----------|--------|
| Reusability | Will this pattern appear in future sessions? | High |
| Impact | If ignored, does it cause real problems? | High |
| Clarity | Can it be expressed as a clear rule/procedure? | Medium |

**Include** findings that score High on Reusability OR Impact.
**Exclude** findings that score Low on both Reusability AND Impact.
**Defer** findings with Low Clarity — ask user for clarification.

## Step 3: Present Findings

Group findings by routing destination and present to the user:

```
## Session Analysis Results

### Skills (반복 워크플로우)

#### 1. [Pattern Name]
- **What it does**: [1-2 sentence description]
- **Evidence**: [Specific conversation moments]
- **Estimated contents**: SKILL.md + [resources]

### CLAUDE.md Rules (규칙/사실)

#### 2. [Rule Name]
- **Rule**: [한 문장 규칙]
- **Evidence**: [What triggered this]
- **Suggested location**: [root/subdir/global]

### Hookify Rules (실수 방지)

#### 3. [Rule Name]
- **Prevent**: [방지할 행동]
- **Evidence**: [When this happened]

### Memory (프로젝트 지식)

#### 4. [Knowledge Name]
- **Fact**: [기록할 사실]
- **Evidence**: [How this was discovered]
```

After presenting all findings, ask: **"어떤 것들을 적용할까요? 번호로 선택하거나, 수정 사항을 알려주세요."**

Do NOT proceed to creation without explicit user approval.

## Step 4: Create Approved Outputs

Read `references/transformation-guide.md` for detailed transformation principles per output type.

### For Skills

1. Create directory: `skills/[skill-name]/`
2. Write `SKILL.md` with third-person description and imperative body
3. Add `references/`, `scripts/`, `examples/` as needed
4. Apply transformation principles: extract final path only, raise abstraction level, make implicit judgments explicit

### For CLAUDE.md Rules

1. Determine appropriate location (root/subdir/global)
2. Format as concise imperative rules
3. Add to existing CLAUDE.md under appropriate section, or create section if needed

### For Hookify Rules

1. Define the behavior to prevent
2. Suggest hookify rule configuration
3. Note: propose the rule; user applies via hookify

### For Memory Entries

1. Check existing memory files for duplicates
2. Add to appropriate topic file or create new one
3. Keep factual and concise

### Quality Checks Before Finalizing

- [ ] 각 출력이 적절한 목적지에 배치되었는가
- [ ] 세션 특정 디테일(파일명, 변수명)이 일반화되었는가
- [ ] 시행착오가 Constraints로 변환되었는가 (워크플로우에 실패 경로 없음)
- [ ] CLAUDE.md 규칙이 한 문장 명령형인가
- [ ] hookify 규칙이 "되돌리기 어려운 피해"를 방지하는 것인가
- [ ] memory 항목이 검증된 사실인가

## Step 5: Verify

### 5-1. 구조 검증

자동으로 수행:
- [ ] 생성된 skill의 `SKILL.md` 파일 존재 확인
- [ ] Frontmatter에 `name`, `description` 필드 존재
- [ ] 본문에서 참조하는 모든 파일이 실제 존재
- [ ] CLAUDE.md 규칙이 올바른 위치에 추가되었는가
- [ ] memory 항목이 중복 없이 추가되었는가

문제 발견 시 즉시 수정하고 사용자에게 보고.

### 5-2. 결과 요약

```
## Session Analysis Complete

| # | Type | Name | Destination | Status |
|---|------|------|-------------|--------|
| 1 | skill | [name] | skills/[name]/ | Created |
| 2 | rule | [name] | CLAUDE.md | Added |
| 3 | hookify | [name] | hookify rule | Proposed |
| 4 | memory | [name] | memory/[file] | Added |

구조 검증: [PASS/수정 사항 목록]
```

### 5-3. 트리거 테스트 제안 (스킬만 해당)

스킬이 생성된 경우, 트리거 테스트 문구를 제안한다:

```
## 트리거 테스트

| 스킬 | 테스트 문구 |
|------|-----------|
| [name] | "[트리거 문구]" |
```

## Edge Cases

- **No findings**: Report honestly. "이 세션에서 보존할 만한 패턴을 찾지 못했습니다. [reason]." Do not force creation.
- **Finding overlaps with existing output**: Propose updating the existing output instead of creating a new one. Present both options to the user.
- **Ambiguous routing**: When a finding could go to multiple destinations, present both options with trade-offs and let the user decide.
- **Very large conversation**: Focus on the most recent coherent workflow if the conversation spans multiple unrelated topics.

## Additional Resources

### Reference Files

- **`references/analysis-criteria.md`** — 5가지 특징 유형의 상세 감지 기준, 판별 순서 Decision Tree, 점수 매트릭스
- **`references/transformation-guide.md`** — 목적지별(skill, CLAUDE.md, hookify, memory) 변환 원칙과 형식
