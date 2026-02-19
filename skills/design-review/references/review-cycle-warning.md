# Review Cycle Warning Signs

## When Review Rounds Indicate Over-Specification

If a design document has gone through 3+ review-fix cycles, the problem is almost certainly NOT that the design has more bugs to find. The problem is that the design contains implementation-level detail that creates cascading consistency requirements.

### The Pattern

1. Review finds inconsistency (e.g., function signature mismatch)
2. Fix is applied (update the signature)
3. Fix creates new inconsistency (callers don't match new signature)
4. Next review finds the new inconsistency
5. Repeat

### The Root Cause

This cycle only occurs when the design contains implementation details:
- Pseudocode with function calls → signatures must be consistent across all call sites
- Resource management patterns → acquire/release must be paired in every code path
- Error handling sequences → state must be valid after every error branch
- Variable declarations → scope must be correct in every try/catch block

### The Fix

The document contains too much "how." Strip it back to "what" and "why":

1. Remove all pseudocode
2. Remove function signatures
3. Remove resource lifecycle patterns
4. Remove error handling sequences
5. Replace with decisions: "resources must be cleaned up on failure" (not HOW to clean them up)

### Quantitative Benchmark

From real experience with a 4-document, ~4,500 line design:

| Review rounds | Total bugs found | Root cause |
|--------------|-----------------|------------|
| 1-6 | 75 | Genuine design gaps |
| 7-10 | 17 | Cross-reference inconsistency in pseudocode |
| 11-14 | 5 | Fixes creating new bugs in pseudocode |
| 15-16 | 2 + convergence | Variable scoping, data flow in pseudocode |

Reviews 7-16 found 24 bugs — all caused by having pseudocode in the design. These bugs would not exist if the design contained only decisions.

### Recommendation

If 3+ review rounds have occurred:

1. Stop reviewing
2. Score the document with the design-review skill
3. Any FAIL on Decision Purity → strip implementation details
4. Re-review the stripped version (should converge in 1 round)
