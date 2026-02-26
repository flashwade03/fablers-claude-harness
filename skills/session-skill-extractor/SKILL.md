---
name: session-skill-extractor
description: This skill should be used when the user asks to "대화에서 스킬 추출해줘", "이 세션에서 스킬 만들 게 있어?", "대화 분석해서 스킬 만들어줘", "session to skill", "extract skill from conversation", "turn this conversation into skills", "what skills can we extract from this session", "이 대화에서 패턴 찾아줘", "스킬로 만들 만한 거 있어?", "세션 리뷰해서 스킬 뽑아줘". Analyzes the current session conversation to identify repeatable workflows, domain knowledge, or multi-step procedures worth turning into reusable skills, then creates them in this plugin.
---

# Session Skill Extractor

## Purpose

Analyze the current session's conversation to discover patterns, workflows, and domain knowledge worth preserving as reusable skills. Turn implicit session knowledge into explicit, structured skills that can be reused across future sessions.

## When NOT to Use

- Session has fewer than ~10 back-and-forth exchanges — not enough signal
- Conversation was purely Q&A with no multi-step workflow or domain procedures
- The identified pattern already exists as a skill in this plugin

## Step 0: Load Existing Skills

Before analysis, scan existing skills to establish a baseline and avoid duplicates.

1. Read all `skills/*/SKILL.md` files in this plugin
2. Note each skill's name, description, and core workflow
3. Keep this list as a deduplication reference throughout the process

## Step 1: Conversation Analysis

Scan the current session conversation and extract candidate patterns. Read `references/analysis-criteria.md` for the detailed signal categories and detection heuristics to apply.

For each candidate found, record:
- **Pattern name**: Short descriptive label
- **Signal type**: Which category from analysis criteria
- **Evidence**: Specific conversation moments that demonstrate the pattern
- **Reuse potential**: How likely this pattern recurs in future sessions

### Analysis Scope

Analyze the ENTIRE conversation from the beginning, not just recent messages. Patterns often emerge from the cumulative flow rather than individual exchanges.

### What to Ignore

- One-off debugging or troubleshooting that won't recur
- Simple tool usage (file reads, edits) without a higher-level workflow
- Patterns already covered by existing skills (from Step 0)
- Generic programming tasks without domain specificity

## Step 2: Score and Filter Candidates

For each candidate, evaluate against three criteria:

| Criterion | Question | Weight |
|-----------|----------|--------|
| Reusability | Will this pattern appear in future sessions? | High |
| Complexity | Does it have 3+ steps or non-obvious domain knowledge? | Medium |
| Distinctness | Is it sufficiently different from existing skills? | High |

**Include** candidates that score High on Reusability AND Distinctness.
**Exclude** candidates that score Low on any criterion.
**Redirect**: For candidates with Low Complexity but High Reusability, propose a CLAUDE.md rule instead of a skill (see scoring matrix in `references/analysis-criteria.md`).

## Step 3: Present Proposals

For each qualifying candidate, present to the user:

```
### Skill Proposal: [Pattern Name]

**What it does**: [1-2 sentence description]
**Why it's worth a skill**: [Reuse justification]
**Estimated contents**:
- SKILL.md: [Core workflow summary]
- references/: [What reference material, if any]
- scripts/: [What scripts, if any]

**Evidence from this session**:
- [Specific moment 1]
- [Specific moment 2]
```

After presenting all proposals, ask: **"어떤 스킬을 만들까요? 번호로 선택하거나, 수정 사항을 알려주세요."**

Do NOT proceed to creation without explicit user approval.

## Step 4: Create Approved Skills

For each approved skill:

1. Create the directory: `skills/[skill-name]/`
2. Add subdirectories as needed: `references/`, `scripts/`, `examples/`
3. Write `SKILL.md` following these rules:
   - **Frontmatter**: Third-person description with specific trigger phrases
   - **Body**: Imperative form, 1,500-2,000 words target
   - **Progressive disclosure**: Core workflow in SKILL.md, details in references/
4. Create referenced resource files

### Skill Content Transformation

Read `references/transformation-guide.md` for the detailed transformation principles and process. Key principles:

1. **최종 경로만 추출**: 시행착오는 워크플로우가 아니라 Constraints("하지 말 것")로 변환
2. **추상화 수준을 올림**: 세션 특정 파일명/변수명을 일반화 (단, 도구/명령이 핵심이면 구체적 유지)
3. **암묵적 판단을 명시적 기준으로**: "복잡하니까 설계부터" → "다음 조건 해당 시 설계 먼저"
4. **사용자 결정 vs AI 결정 구분**: 사용자 결정 → "사용자에게 물어볼 것", AI 결정 → 워크플로우 스텝

변환 후 검증 질문 3가지:
- "이 세션의 프로젝트를 모르는 사람이 읽어도 이해되는가?"
- "이 스텝을 빼면 워크플로우가 깨지는가?"
- "이 내용은 다른 프로젝트에서도 유효한가?"

### Quality Checks Before Finalizing

- [ ] SKILL.md frontmatter has third-person description with trigger phrases
- [ ] Body uses imperative form (not second person)
- [ ] Body is under 3,000 words (ideally 1,500-2,000)
- [ ] All referenced files exist
- [ ] No duplication with existing skills (Step 0 check)
- [ ] Skill captures the essence of the pattern, not session-specific details
- [ ] 세션 특정 디테일(파일명, 변수명)이 일반화되었는가
- [ ] 시행착오가 Constraints로 변환되었는가 (워크플로우에 실패 경로 없음)

## Step 5: Verify and Iterate

스킬 생성 후 바로 검증한다. 만들고 끝이 아니라, 작동 확인까지가 이 스킬의 범위이다.

### 5-1. 구조 검증

자동으로 수행:
- [ ] `skills/[name]/SKILL.md` 파일 존재 확인
- [ ] Frontmatter에 `name`, `description` 필드 존재
- [ ] `description`이 "This skill should be used when" 패턴
- [ ] 본문에서 참조하는 모든 파일(`references/`, `scripts/`)이 실제 존재

문제 발견 시 즉시 수정하고 사용자에게 수정 사항을 보고.

### 5-2. 트리거 테스트 제안

사용자에게 트리거 테스트를 제안한다:

```
## 트리거 테스트

생성된 스킬이 의도대로 트리거되는지 확인하려면, 새 세션에서 다음 문구를 시도해 보세요:

| 스킬 | 테스트 문구 |
|------|-----------|
| [name] | "[description에서 추출한 트리거 문구 1]" |
| [name] | "[트리거 문구 2]" |
```

### 5-3. 결과 요약

```
## Created Skills

| Skill | Path | Description |
|-------|------|-------------|
| [name] | skills/[name]/ | [1-line summary] |

구조 검증: [PASS/수정 사항 목록]
```

### 5-4. 이후 개선

스킬을 실제로 사용한 후 개선이 필요하면, 다음 세션에서 이 스킬을 다시 호출하거나 직접 SKILL.md를 수정한다. 일반적인 개선 사항:
- 트리거 문구 추가 (실제 사용자가 쓴 표현이 description에 없을 때)
- 워크플로우 스텝 순서 조정
- 누락된 Constraints 추가 (실제 사용 시 발견된 함정)

## Edge Cases

- **No candidates found**: Report honestly. "이 세션에서 스킬로 만들 만한 반복 패턴을 찾지 못했습니다. [reason]." Do not force skill creation.
- **Candidate overlaps with existing skill**: Propose updating the existing skill instead of creating a new one. Present both options to the user.
- **Very large conversation**: Focus on the most recent coherent workflow if the conversation spans multiple unrelated topics.
- **User wants to modify a proposal**: Incorporate feedback and re-present before creating.

## Additional Resources

### Reference Files

- **`references/analysis-criteria.md`** — Detailed signal categories and detection heuristics for identifying skill-worthy patterns in conversations
- **`references/transformation-guide.md`** — Conversation-to-skill transformation principles, process, and common pitfalls
