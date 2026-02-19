---
name: vibe-design
description: This skill should be used when the user asks to "design a feature", "create architecture", "plan a system", "how much design do I need?", "should I write a spec?", "is this over-engineered?", "설계해줘", "아키텍처 잡아줘", "설계 범위 정해줘", "기획 문서 써야 할까?", or when the user is about to enter plan mode for a non-trivial feature. Guides design scope to match requirement size using 3 levels (no design, inline design, document design), preventing over-specification that kills vibe coding productivity.
---

# Vibe Design

## Purpose

Guide the design process to produce exactly the right amount of specification for vibe coding. Design = Decisions + Constraints + Milestones. Never pseudocode, function signatures, or exhaustive error paths.

Over-specification is as harmful as under-specification. Pseudocode in design documents creates consistency problems that require endless review cycles. AI can generate implementation from decisions — specifying implementation details constrains AI and introduces bugs that wouldn't exist otherwise.

## Step 1: Determine Scope Level

Before any design work, classify the requirement:

### Level 0: No Design Needed

**Condition**: Requirement completes within existing code structure.

- Bug fixes, text changes, style adjustments, config tweaks
- No new architectural decisions required

**Action**: Implement directly. No design document, no design discussion.

### Level 1: Inline Design

**Condition**: New feature that extends existing architecture through established patterns.

- Adding a component, endpoint, or handler where the pattern already exists
- Extension points are already in place

**Action**: State constraints directly in the implementation prompt. No separate document.

Format:
```
"[Feature description].
- [Key decision 1]
- [Key decision 2]
- Constraint: [what must/must not happen]"
```

### Level 2: Document Design

**Condition**: New structural decisions needed that downstream features will depend on.

- New project initialization
- New subsystem (authentication, real-time sync, etc.)
- Decisions that change how future features get built

**Action**: Write a design document scoped to the NEXT milestone only.

## Step 2: Scope Boundary (Level 2 Only)

Before writing, define the milestone boundary. Ask:

> "What is the smallest thing I can build that works end-to-end?"

That is v0. Design ONLY v0. Everything else is deferred.

Example milestones for a web service (adapt to the actual project):

| Milestone | Design Now | Defer to Later |
|-----------|-----------|----------------|
| v0: Basic end-to-end flow | Core structure, execution method, data flow | Multi-tenancy, error recovery, optimization |
| v1: Multi-user/project | Isolation strategy, resource management | Monitoring, graceful degradation |
| v2: Production stability | Recovery, health checks, shutdown | Analytics, A/B testing, scaling |

Each version must work independently. The design for v1 should not require changing v0's architecture.

## Step 3: Domain Decision Checklist (Level 2 Only)

Before writing the design document, load the relevant domain checklist to ensure no critical decisions are missed. The checklist asks "have you decided about X?" — it does NOT prescribe what to decide.

Available domain checklists:
- **`references/domain-web-service.md`** — Web service / API / real-time app
- Add more domain files as needed

If no domain checklist exists for the project type, identify decision categories by asking:
1. How does data flow between components?
2. What are the external dependencies?
3. What must this system NOT do?

## Step 4: Apply the 5 Principles

When writing a Level 2 design document, follow these principles strictly. Read `references/principles.md` before writing a Level 2 design document for the first time.

1. **Decisions Only** — Record what was decided and why. Not implementation.
2. **Why, Not How** — AI generates implementation from decisions. Specifying "how" creates constraints and cascading consistency issues.
3. **Context Window Budget** — The design is AI's system prompt. Core design must fit ~200-300 lines. Details go in separate reference files.
4. **Milestone-Scoped** — Design only what the next milestone requires. Defer everything else explicitly.
5. **Constraints Over Prescriptions** — Tell AI what NOT to do. Leave the rest to AI's judgment.

## Step 5: Write the Design Document

Use this template. Save to `docs/plans/YYYY-MM-DD-<topic>-design.md`.

```markdown
# [Feature/Milestone Name]

## Goal
One sentence describing what this milestone delivers.

## Tech Stack
- [Component]: [technology] — because [why]
- [Component]: [technology] — because [why]

## Architectural Decisions
- **[Decision]**: [what] — because [why]
- **[Decision]**: [what] — because [why]

## Constraints
- Must: [hard requirement]
- Must not: [prohibited approach]

## Scope
**In scope**: [what this version delivers]
**Out of scope**: [explicitly deferred to future milestones]

## Open Questions
Decisions deferred to future milestones.
```

**What NOT to include:**
- Function signatures or interfaces
- Pseudocode or implementation details
- Error handling for every edge case
- Database schemas with exact column types
- API response formats

These are implementation decisions. AI makes them during coding, guided by the architectural decisions and constraints above.

## Step 6: Validate

Before moving to implementation, check:

- [ ] Can the design fit as a section in CLAUDE.md? (~200-300 lines)
- [ ] Does every sentence describe a DECISION or CONSTRAINT, not an implementation?
- [ ] Is the scope limited to ONE milestone?
- [ ] Would removing any section make implementation ambiguous? (If not, remove it)
- [ ] Are deferred items explicitly listed in "Out of scope"?

If any check fails, the design is over-specified. Trim it.

## Step 7: Reflect into CLAUDE.md

The design document is a working artifact for review. CLAUDE.md is what AI reads during implementation. After the design is approved, reflect decisions into CLAUDE.md:

| Design Document Section | CLAUDE.md Section |
|------------------------|-------------------|
| Tech Stack | `## 기술 스택` |
| Architectural Decisions | `## 아키텍처` |
| Constraints | `## 규칙` |
| Scope (what's in/out) | `## 워크플로우` or milestone notes |

**Rules for CLAUDE.md reflection:**
- Strip the "because [why]" rationale — CLAUDE.md states facts, not reasoning
- Keep it imperative: "서버는 TypeScript로 작성한다" not "TypeScript를 선택했는데 이유는..."
- If CLAUDE.md already has the relevant sections, UPDATE them. Do not create duplicates.
- Design document stays in `docs/plans/` as history. CLAUDE.md is the living source of truth.

## Workflow Summary

```
Requirement received
  → Changes within existing code? → Level 0: Implement directly
  → Extends existing architecture? → Level 1: Constraints in prompt
  → New structural decisions? → Level 2:
      1. Define milestone boundary (smallest working thing)
      2. Load domain checklist → identify decisions needed
      3. Apply 5 principles → write design document
      4. Validate: fits in context, decisions-only, one milestone
      5. Get user approval
      6. Reflect into CLAUDE.md
      7. Proceed to implementation
```

## Common Mistakes

Before proceeding to implementation, review the checklist below. If the design has gone through more than 2 review rounds, read `references/anti-patterns.md` for root-cause analysis.

**Quick checklist of what to avoid:**
- Writing pseudocode and calling it "design"
- Designing the finished product when building v0
- Specifying function signatures before writing code
- Adding error handling to the design (AI handles this during implementation)
- Creating separate documents for things that fit in one prompt
- Leaving design decisions only in docs/plans/ without reflecting into CLAUDE.md

## Additional Resources

### Reference Files

- **`references/principles.md`** — Detailed explanation of the 5 design principles with extended examples and rationale
- **`references/anti-patterns.md`** — Over-specification failure modes derived from real 16-round design review experience
- **`references/domain-web-service.md`** — Decision checklist for web service projects
