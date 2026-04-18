<div align="center">

# fablers

**Stop prompting. Start harnessing.**

A Claude Code plugin marketplace packaging battle-tested workflows into reusable plugins.
Design methodology, document forging, and agentic RAG — all in one place.

[![Claude Code Marketplace](https://img.shields.io/badge/Claude_Code-Marketplace-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.9.0-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## Plugins

### `vibe-architecture` — Design methodology & skill extraction

Encodes proven design methodologies into skills that Claude loads on demand. No more ad-hoc prompting — just structured workflows that actually work.

| Skill | What it does |
|-------|-------------|
| **vibe-design** | Turn rough ideas into just-enough design specs. Decisions + Constraints + Milestones, never pseudocode. |
| **design-review** | Score design docs against 6 axes (S~F grade, 0-100 score). Any FAIL caps the grade at C. |
| **sketch-team-orchestrator** | Agent Teams workflow for **concrete multi-domain design** with adversarial critique: 1–3 Specialist Designers (data-model / api-surface / protocol / etc., Lead-decided) produce concrete artifacts, a Challenger pushes weakest-assumption / alternative-framing / missed-edge-case critiques (use `-c` for per-specialist critics), Planner integrates critique with cross-domain coherence, 2 Reviewers judge against a concretion-friendly 6-axis rubric, loop until approved. |
| **session-skill-extractor** | Analyze conversations to extract reusable patterns. Routes findings to skills, CLAUDE.md, hookify, or memory. |

```
> /sketch                          # Start a design (single-agent Q&A)
> /sketch-team <task>              # Agent Teams: design + review bundled, auto-iterates
> 설계 리뷰해줘                      # Review a design
> 대화에서 스킬 추출해줘              # Extract skills from session
```

---

### `damascus` — Forge documents through iterative multi-LLM review

> *Like Damascus steel, documents become stronger through repeated forging.*

Refines documents through an iterative review loop powered by multiple LLMs. Write an implementation plan or technical document, have it reviewed by Claude, Gemini, and OpenAI in parallel, then refine until approved.

```
> /forge <task description>        # Single-reviewer forging
> /forge-team <task description>   # Multi-LLM team review
> /forge-plan <task description>   # Plan-only mode
> /forge-doc <task description>    # Document-only mode
```

---

### `fablers-agentic-rag` — Ask your documents. Get a cited answer.

Agentic RAG pipeline — query analysis, hybrid retrieval (vector + BM25), CRAG validation, and cited answer synthesis — all orchestrated by Claude agents. Supports PDF, plain text, and Markdown.

```
> /ingest <file>                   # Index a document
> /ask <question>                  # Query with citations
> /search <query>                  # Raw retrieval
```

---

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add flashwade03/fablers-claude-plugins

# Install individual plugins
/plugin install vibe-architecture@fablers
/plugin install damascus@fablers
/plugin install fablers-agentic-rag@fablers
```

---

## Project Structure

```
fablers/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── vibe-architecture/         # Design methodology
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/
│   │   └── skills/
│   │       ├── vibe-design/
│   │       ├── design-review/
│   │       └── session-skill-extractor/
│   ├── damascus/                       # Document forging
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   ├── commands/
│   │   ├── hooks/
│   │   ├── scripts/
│   │   └── skills/
│   └── fablers-agentic-rag/            # Agentic RAG
│       ├── .claude-plugin/plugin.json
│       ├── agents/
│       ├── commands/
│       ├── hooks/
│       ├── scripts/
│       └── skills/
```

---

## Philosophy

1. **Decisions, not implementation** — Design documents record *what* and *why*, never *how*
2. **Progressive disclosure** — Core workflow loads first, details load only when needed
3. **Earn your complexity** — Simple patterns stay simple. Skills are created only when the pattern justifies one

---

## License

MIT
