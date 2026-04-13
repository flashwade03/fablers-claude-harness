# vibe-architecture

Vibe coding design methodology — structured design, 6-axis review scoring, Agent Teams design+review bundle, and session skill extraction.

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

### sketch-team-orchestrator

Bundle design + review into one Agent Teams workflow. Lead holds the user dialogue (vibe-design Step 0.5–1.5); then a team of Designers (1–3, parallel, distinct approaches) → Planner (cross-pollinate + synthesize) → Scribe (write) → Reviewers (Content + Structure, 6-axis rubric) runs autonomously, looping until APPROVED or `max_rounds` reached.

- **Variable Designer count**: Lead picks 1–3 based on how contested the trade-off space is
- **Two-pass exploration**: preliminary approaches → peer cross-pollination → refined approaches → synthesis
- **Single writer (Scribe)**: design.md and .review.md — clean role boundaries, no file conflicts
- **Strict rubric verdict**: any axis FAIL → NEEDS_REVISION; max_rounds cap (default 3); escalate to user if cap hit

**Requires** `.claude/settings.json` with:
```json
{
  "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": 1,
  "teammateMode": "tmux"
}
```
`teammateMode: "tmux"` is optional but recommended — it opens a split pane per teammate so you can watch them work.

```
> /sketch-team design a job queue that handles retries and priorities
> /sketch-team -n 5 architect multi-tenant data isolation
> /sketch-team -o docs/features/notifications.md design the notification system
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
| `/sketch` | Start vibe-design interactively (single-agent Q&A) |
| `/sketch-team` | Agent Teams workflow — design + review bundled, auto-iterates until approved or max_rounds hit |
