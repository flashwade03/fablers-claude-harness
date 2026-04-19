<div align="center">

# grimoire

**A book of reusable Claude Code skills.**

Not a single-purpose plugin. A growing collection of general-purpose skills that aren't tied to any one command or workflow — the kind Claude should pull out whenever the situation calls for them, regardless of which other plugin is active.

Named `grimoire` because it's a book of reusable patterns. This README compensates for the metaphor.

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](../../LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## Skills

| Skill | What it does |
|-------|-------------|
| **agent-teams** | Run *real* Claude Code agent teams (TeamCreate + SendMessage) for debates, reviews, and implementation — instead of letting a single agent role-play multiple personas. Includes cross-challenge patterns, worked examples, and explicit scope boundaries against `/forge-team`. |

More skills will be added as reusable patterns surface.

---

## When skills trigger

Skills in grimoire are activated by natural-language intent — you don't invoke them via slash commands. Examples:

```
> 에이전트 팀 만들어줘               # spawns the agent-teams skill
> debate with agent teams          # same — for a structured cross-agent debate
> coordinate 3 agents to review X  # same
```

Each skill has its own trigger keywords in its `description` frontmatter. Claude chooses the right skill based on the user's phrasing.

---

## Installation

```bash
/plugin marketplace add flashwade03/fablers-claude-plugins
/plugin install grimoire@fablers
```

No config file needed. Skills load on demand.

### Prerequisites

`agent-teams` requires Claude Code's experimental agent-teams flag:

```json
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## Project Structure

```
grimoire/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── agent-teams/
        └── SKILL.md
```

---

## Why the name

`damascus`, `sketch`, `forge` are already metaphor-named brand plugins in this marketplace. `grimoire` fits that family — a book of patterns, always on the shelf, pulled out when needed. Direct names like `common-skills` or `reusable-patterns` were considered; `grimoire` won for consistency with sibling plugins.

The tradeoff: metaphor names need explanatory prose to be useful. That's what this page is.

---

## License

MIT
