# vibe-architecture

Vibe coding design methodology — structured design, 6-axis review scoring, and session skill extraction.

## Skills

### vibe-design

Turn rough ideas into just-enough design specs. Covers the full spectrum from idea exploration to structured design documents.

- **Scope check**: Is a design doc even needed? If not, skip and build.
- **1-question-at-a-time dialogue**: Propose 2-3 approaches with trade-offs.
- **Decision maturity**: Confirmed decisions get rationale. Candidates stay as bullets.
- **Output**: ~200-300 lines of decisions and constraints, never pseudocode.

```
> /sketch                 # recommended — always loads the skill
> 설계해줘                  # natural-language triggers may not fire reliably
> 아키텍처 잡아줘
```

Natural-language phrasing doesn't consistently trigger the skill — Claude often handles broad design talk directly. Use `/sketch` when you want the methodology loaded explicitly.

### design-review

Score design documents against 6 vibe coding axes. Outputs Grade (S~F), Score (0-100), and actionable feedback.

| Axis | What it checks |
|------|---------------|
| Decision Purity | Every statement is a decision, not implementation |
| Rationale Presence | Every decision explains why |
| Decision Maturity | Confirmed vs candidate decisions are clearly separated |
| Context Budget | Fits in ~200-300 lines |
| Constraint Quality | Boundaries, not prescriptions |
| CLAUDE.md Alignment | Design doc is linked, not duplicated |

Any single FAIL caps the grade at C.

```
> 설계 리뷰해줘
> score this design
> design quality check
```

### session-skill-extractor

Analyze the current conversation to extract reusable patterns. Routes each finding to the best destination:

- **Repeatable workflows** → new skill
- **Explicit rules** → CLAUDE.md
- **Corrections** → hookify rule
- **Domain knowledge** → memory

```
> 대화에서 스킬 추출해줘
> 세션 회고
> turn this conversation into skills
```

## Commands

| Command | Description |
|---------|-------------|
| `/sketch` | Start vibe-design interactively |
