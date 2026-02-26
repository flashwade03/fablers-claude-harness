<div align="center">

# fablers-claude-harness

**Stop prompting. Start harnessing.**

A Claude Code plugin that encodes battle-tested design methodologies into reusable skills.
No more ad-hoc prompting — just structured workflows that actually work.

[![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.2.6-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## Why?

AI-assisted coding is powerful, but without structure it's chaos. You end up with:
- Over-specified designs that kill productivity
- Under-specified designs that produce garbage
- The same workflows reinvented every session

**fablers-claude-harness** solves this by packaging proven methodologies as skills that Claude loads on demand.

---

## Skills

### `vibe-design` — Design just enough, never too much

> *"Design = Decisions + Constraints + Milestones. Never pseudocode."*

Guides you to produce exactly the right amount of specification for vibe coding. No more 8,000-word design docs that nobody reads.

| Step | What happens |
|------|-------------|
| Scope Check | Is a design doc even needed? If not, skip and build. |
| User Dialogue | One question at a time. Choices over open-ended questions. |
| Decision Maturity | Confirmed decisions get rationale. Candidates stay as bullets. |
| Domain Checklist | No critical decisions fall through the cracks. |
| Write & Validate | Output fits ~200-300 lines. Every line is a decision, not implementation. |

```
> 설계해줘
> design a feature
> 아키텍처 잡아줘
```

---

### `design-review` — 6-axis scoring, S to F grade

> *"If it has pseudocode, it's not a design document."*

Scores any design document against 6 axes derived from real over-specification failures. Outputs a grade, a score, and exactly what to fix.

```
Grade: A | Score: 83

┌─────────────────────┬───────┬────────┐
│ Axis                │ Grade │ Points │
├─────────────────────┼───────┼────────┤
│ Decision Purity     │ PASS  │   2    │
│ Rationale Presence  │ PASS  │   2    │
│ Decision Maturity   │ WARN  │   1    │
│ Context Budget      │ PASS  │   2    │
│ Constraint Quality  │ PASS  │   2    │
│ CLAUDE.md Alignment │ WARN  │   1    │
└─────────────────────┴───────┴────────┘
```

Any single **FAIL** caps the grade at C. No shipping designs with fundamental issues.

```
> 설계 리뷰해줘
> review my design
> score this design
```

---

### `session-skill-extractor` — Turn conversations into skills

> *"Your best workflows shouldn't die when the session ends."*

Analyzes your current conversation to find patterns worth preserving. If it finds something, it builds the skill for you.

**How it works:**

1. Scans the entire conversation for 6 signal types
2. Scores candidates by reusability, complexity, and distinctness
3. Presents proposals — you pick what to create
4. Builds the skill with proper structure, trigger phrases, and references
5. Verifies the output before finishing

Low-complexity patterns get redirected to CLAUDE.md rules instead of full skills. No skill bloat.

```
> 대화에서 스킬 추출해줘
> extract skill from conversation
> 이 세션에서 스킬 만들 게 있어?
```

---

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add flashwade03/fablers-claude-plugins

# Install the plugin
/plugin install fablers-claude-harness@fablers
```

For local development:

```bash
claude --plugin-dir /path/to/fablers-claude-harness
```

---

## Project Structure

```
fablers-claude-harness/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace metadata
└── skills/
    ├── vibe-design/             # Design methodology
    │   ├── SKILL.md
    │   └── references/
    │       ├── principles.md
    │       ├── anti-patterns.md
    │       └── domain-web-service.md
    ├── design-review/           # 6-axis review scoring
    │   ├── SKILL.md
    │   ├── references/
    │   └── examples/
    └── session-skill-extractor/ # Conversation → Skill
        ├── SKILL.md
        └── references/
            ├── analysis-criteria.md
            └── transformation-guide.md
```

---

## Philosophy

This plugin follows three principles:

1. **Decisions, not implementation** — Design documents record *what* and *why*, never *how*
2. **Progressive disclosure** — Core workflow loads first, details load only when needed
3. **Earn your complexity** — Simple patterns stay simple. Skills are created only when the pattern is complex enough to justify one

---

## License

MIT
