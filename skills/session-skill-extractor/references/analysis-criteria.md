# Conversation Analysis Criteria

## Signal Categories

When scanning a conversation for skill-worthy patterns, look for these six signal types. Each represents a different kind of reusable knowledge.

### 1. Repeated Multi-Step Workflow

**What it is**: A sequence of 3+ actions that were performed in a specific order to achieve a goal, especially if the sequence was repeated or refined during the session.

**Detection heuristics**:
- Same sequence of tool calls appeared more than once
- User described a process with numbered steps
- Claude followed a consistent procedure across multiple items (e.g., reviewing several files the same way)

**Example signals**:
- "First read the config, then validate against schema, then update the test file"
- Same pattern of read → analyze → edit applied to multiple files
- A debugging workflow: reproduce → isolate → fix → verify

**Skill potential**: High — workflows are the most natural fit for skills.

### 2. Domain-Specific Decision Framework

**What it is**: A set of criteria or rules used to make decisions in a specific domain. The criteria are non-obvious and required discovery or user explanation.

**Detection heuristics**:
- User explained business rules ("우리는 항상 X 방식으로 한다")
- Multiple conditional branches based on domain knowledge
- Claude needed correction because it didn't know a domain convention

**Example signals**:
- "If the API returns 429, we back off exponentially but cap at 30s"
- "Our naming convention for migrations is YYYYMMDD_description"
- "Design documents should never contain implementation details"

**Skill potential**: High — domain knowledge is exactly what AI models lack.

### 3. Quality Gate / Review Checklist

**What it is**: A set of checks applied to validate output quality. Emerged naturally from the conversation as things to verify.

**Detection heuristics**:
- User asked "did you check X?" after Claude's output
- Claude performed a validation step that caught issues
- A list of criteria was established through iteration

**Example signals**:
- "Before committing, always run lint and check for unused imports"
- "Every design document needs a Goal section and Constraints section"
- A scoring rubric that was applied to evaluate something

**Skill potential**: Medium-High — great for review/validation skills.

### 4. Tool Configuration Pattern

**What it is**: A specific way of using tools (CLI commands, API calls, file operations) that required non-trivial setup or configuration.

**Detection heuristics**:
- Complex command-line invocations with specific flags
- Tool chains where output of one feeds into another
- Configuration that took multiple tries to get right

**Example signals**:
- Specific ffmpeg command for a media processing task
- A curl + jq pipeline for API data extraction
- Build configuration that resolved a tricky dependency issue

**Skill potential**: Medium — good candidate for scripts/ in a skill.

### 5. Iterative Refinement Pattern

**What it is**: A pattern where an initial approach was refined through multiple iterations, and the final approach represents learned knowledge about what works.

**Detection heuristics**:
- Multiple revisions of the same artifact
- User corrections that revealed non-obvious requirements
- Claude's approach changed significantly after feedback

**Example signals**:
- First design was over-specified → refined to decisions-only
- Initial regex didn't handle edge cases → final version covers them all
- Prompt template went through 3 iterations before user approved

**Skill potential**: Medium — the final approach is valuable, but the iteration itself may be too session-specific.

### 6. Cross-Cutting Convention

**What it is**: A convention or rule that applies across multiple files, components, or tasks. Often implicit until made explicit.

**Detection heuristics**:
- Same principle applied to different files/components
- User stated a rule that should "always" or "never" apply
- A pattern was enforced consistently across the session

**Example signals**:
- "All error messages should be in Korean"
- "Every new component needs a corresponding test file"
- "We always use absolute imports, never relative"

**Skill potential**: Low-Medium — often better suited for CLAUDE.md rules than full skills. Promote to skill only if the convention requires a multi-step workflow to enforce.

## Scoring Matrix

For each candidate, assess:

| Criterion | High | Medium | Low |
|-----------|------|--------|-----|
| **Reusability** | Will recur in most sessions | Will recur occasionally | One-off or rare |
| **Complexity** | 5+ steps or deep domain knowledge | 3-4 steps or moderate domain knowledge | 1-2 steps, obvious logic |
| **Distinctness** | No overlap with existing skills | Partial overlap but different focus | Mostly duplicates an existing skill |

### Decision Rules

- **All High** → Strong candidate. Create the skill.
- **High Reusability + High Distinctness + Medium Complexity** → Good candidate. Create the skill.
- **Any Low** → Weak candidate. Skip unless user specifically requests it.
- **Low Distinctness** → Propose updating the existing skill instead.
- **Low Complexity + High Reusability** → Better as a CLAUDE.md rule than a skill. Suggest this to the user.

## Distinguishing Skills from CLAUDE.md Rules

Not every pattern deserves a full skill. Consider:

| Characteristic | CLAUDE.md Rule | Skill |
|---------------|---------------|-------|
| Length | 1-3 lines | Multi-step workflow |
| Trigger | Always active | On-demand activation |
| Content | Fact or constraint | Procedure with decisions |
| Context cost | Minimal (always loaded) | Progressive (loaded when needed) |

**Rule of thumb**: If the pattern can be expressed as a single imperative sentence ("Always do X when Y"), it's a CLAUDE.md rule. If it requires a workflow with decision points, it's a skill.
