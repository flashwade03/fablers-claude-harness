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

Produce **concrete multi-domain designs** via Agent Teams. Where `/sketch` (vibe-design alone) keeps decisions abstract for AI to fill in later, `/sketch-team` deliberately concretises — interfaces, data shapes, sequence diagrams — because in some domains the concrete artifact *is* the decision (API contracts, message protocols, data models with cascading types).

Lead holds the user dialogue (vibe-design Step 0.5–1.5), picks 1–3 **Specialist Designers** based on the task's natural domain decomposition (e.g., `data-model`, `api-surface`, `protocol`), then the team runs autonomously:

- **Specialist roster, Lead-decided per task**: not "approaches" to the same problem — each Designer is the team's expert in one domain
- **Two-pass coherence**: preliminary domain artifacts → Planner builds peer summary + cross-domain conflicts → refined artifacts → composition. Rejected alternatives Specialists considered surface inline as `Alternative considered: X — rejected because Y`.
- **Single writer (Scribe)**: design.md and .review.md — clean role boundaries, no file conflicts
- **Concretion-friendly 7-axis rubric**: Specification Productivity / Rationale Presence / Decision Maturity / Failure Coverage / Specialist Coherence / Constraint Quality / CLAUDE.md Alignment. Allows load-bearing concrete artifacts (signatures, schemas, sequence diagrams) but rejects decorative pseudocode. Failure Coverage checks that critical failure modes are explicitly named with handling decisions.
- **Strict verdict + max_rounds cap**: any axis FAIL → NEEDS_REVISION; cap default 3; escalate to user if hit

**Requires** `.claude/settings.json` with:
```json
{
  "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" },
  "teammateMode": "tmux"
}
```
`teammateMode: "tmux"` is optional but recommended — it opens a split pane per teammate so you can watch them work.

```
> /sketch-team design a job queue that handles retries and priorities
> /sketch-team -n 5 architect multi-tenant data isolation
> /sketch-team -o docs/features/notifications.md design the notification system
```

**When to use which**: `/sketch` for early-stage thinking where leaving implementation open is the right call. `/sketch-team` for designs where the concretion itself decides things (API contracts, message protocols, multi-domain data shapes).

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
