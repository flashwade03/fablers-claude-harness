# Design Anti-Patterns for Vibe Coding

Derived from a real experience: 16 rounds of design review across 4 documents (~4,500 lines), finding and fixing 115 cross-reference bugs before achieving consistency. The design achieved "S-tier" internal consistency — and was simultaneously unsuitable for vibe coding implementation.

## Anti-Pattern 1: Pseudocode as Design

**What happens**: Design documents include function implementations, complete with parameters, return types, error handling, and control flow.

**Why it seems right**: Pseudocode makes the design "precise" and "unambiguous."

**Why it fails**:
- Every function signature must be consistent with every call site across all documents
- Every error path must correctly update state, release resources, and notify consumers
- Variable scoping, data structure access patterns, and lifecycle management all become design concerns
- The result is a design that requires code review, not design review

**Real example**: `allocatePort() → reservedPorts.add() → releasePortReservation()` was specified as a design pattern. This created 10 bugs across 7 reviews (the "resource release" pattern). These bugs would not exist if the design simply said "ports are dynamically allocated and released when no longer needed."

**Fix**: State the decision ("dynamic port allocation"). Let AI determine the implementation mechanism.

## Anti-Pattern 2: Finished-Product Design for v0

**What happens**: The very first design document describes the complete system — error recovery, health monitoring, graceful shutdown, concurrent user handling — all for what's supposed to be an MVP.

**Why it seems right**: "We know we'll need these eventually, so let's design them now."

**Why it fails**:
- Can't build v0 without implementing v2's error handling (because v0's state machine already includes error states that reference v2's recovery mechanisms)
- Every feature is entangled with every other feature in the design
- Incremental development becomes impossible — must build everything or nothing
- Context window is consumed by decisions that won't be implemented for weeks/months

**Real example**: A system designed for 2 concurrent users included dynamic port allocation (range 5173-5199, 27 ports), port reservation sets, proxy registration/deregistration pairs for 9 code paths, health sweep with zombie detection, and crash recovery with automatic restart — all in Phase 1. A hardcoded port would have served v0.

**Fix**: Design the smallest working thing. Add complexity when it's needed, not when it's imagined.

## Anti-Pattern 3: Review-Fix Cycle Bloat

**What happens**: Each review finds issues → fixes are applied → fixes create new issues → next review finds those → more fixes → documents grow.

**Why it seems right**: "We're making the design more robust with each iteration."

**Why it fails**:
- Documents only grow, never shrink (fixes add code, rarely remove it)
- Each fix can create 1-2 new issues (especially in pseudocode where consistency is fragile)
- Reviews expand scope naturally — checking error paths leads to checking resource lifecycle leads to checking variable scoping
- After 16 rounds, the documents contained implementation-level detail that belonged in code, not design

**Convergence curve from real experience**:
```
Review  7:  3 bugs (first cross-reference review)
Review  8:  6 bugs (new verification axis: function signatures)
Review  9:  5 bugs
Review 10:  3 bugs
Review 11:  2 bugs
Review 12:  1 bug
Review 13:  1 bug (fix from 12 created new issue)
Review 14:  1 bug (fix from 13 created new issue)
Review 15:  2 bugs (new verification axis: data flow, variable scope)
Review 16:  0 bugs (convergence)
```

The curve shows: pseudocode consistency IS achievable, but at enormous cost — and the "consistent pseudocode" is still not compilable code. It's the worst of both worlds: expensive to maintain like code, but not executable like code.

**Fix**: If a design needs code review to validate, it contains too much implementation detail. Strip it back to decisions and constraints.

## Anti-Pattern 4: Design Scope Creep via Review

**What happens**: Reviewers (human or AI) naturally expand the scope of what they check. Starting from "are the state transitions consistent?" leads to "are the function signatures consistent?" leads to "are the resource lifecycles complete?" leads to "are the variable scopes correct?"

**Why it seems right**: Each expansion catches real issues.

**Why it fails**:
- The expanded scope belongs to implementation, not design
- Design review becomes indistinguishable from code review
- The boundary between design and implementation dissolves
- When it's time to actually implement, the design→plan→implement pipeline becomes opaque because the design already IS (bad) implementation

**Real example**: Starting from state machine consistency (design concern), reviews expanded to:
- Function signatures across call sites (implementation concern)
- try/catch variable scoping (implementation concern)
- Map.set()/Map.delete() producer-consumer completeness (implementation concern)
- `typeof` behavior on undeclared variables (language-level concern)

All legitimate issues — but none of them belong in a design document.

**Fix**: When a review finds something that would be caught by a linter, test, or code review — it's an implementation issue. Note it as a known risk and move on.

## Anti-Pattern 5: Design Documents as Source of Truth

**What happens**: Design documents are treated as the authoritative specification. Implementation must match the document exactly. Changes require document updates first.

**Why it seems right**: Maintains traceability and consistency.

**Why it fails for vibe coding**:
- Vibe coding's strength is rapid iteration — change the prompt, get new code
- If every code change requires a document update, iteration speed collapses
- Documents become stale immediately after implementation begins
- Two sources of truth (document + code) always diverge

**Fix**: Design documents are DISPOSABLE. They capture decisions made at a point in time. Once implementation begins, the code is the source of truth. The design document is history, not law. CLAUDE.md captures the living architectural constraints; design docs capture the reasoning that led to them.

## Summary: The Design Spectrum

```
Under-specified                                    Over-specified
     |                                                   |
"make a game thing"    [sweet spot]    "4,500 lines of pseudocode"
     |                      |                            |
  AI guesses         AI decides within            AI transcribes
  everything         constraints                  from spec
```

The sweet spot: enough decisions to prevent AI from making wrong architectural choices, few enough details that AI exercises judgment on implementation.
