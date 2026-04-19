<div align="center">

# grimoire

**再利用可能なClaude Codeスキルの書。**

単一目的プラグインではありません。特定のコマンドやワークフローに紐付かない汎用スキルの成長するコレクション — どのプラグインが有効でも、状況に応じてClaudeが取り出す種類のパターンです。

`grimoire`は「再利用パターンの書」というメタファーです。今読んでいるこのREADMEが、そのメタファーの不親切さを補っています。

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](../../LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## スキル

| スキル | 内容 |
|--------|------|
| **agent-teams** | 単一エージェントが複数のペルソナを演じる"偽物のチーム"ではなく、本物のClaude Code agent team（TeamCreate + SendMessage）を起動してdebate / review / implementation を実行。cross-challenge プロンプトパターン、worked example、`/forge-team`との境界明示を含む。 |

再利用パターンが蓄積されるたびにスキルが追加されます。

---

## スキルの発動方法

grimoireのスキルはスラッシュコマンドではなく、自然言語の意図で活性化されます：

```
> エージェントチームを作って           # agent-teams スキル発動
> debate with agent teams          # 同じ — 構造化されたcross-agent debate
> 3エージェントでXをレビューして        # 同じ
```

各スキルは自身の`description`フロントマターにトリガーキーワードを持ち、Claudeがユーザーの表現に合わせて適切なスキルを選択します。

---

## インストール

```bash
/plugin marketplace add flashwade03/fablers-claude-plugins
/plugin install grimoire@fablers
```

個別の設定ファイルは不要です。スキルは必要に応じてロードされます。

### 前提条件

`agent-teams`にはClaude Codeの実験的agent-teamsフラグが必要です：

```json
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## プロジェクト構造

```
grimoire/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── agent-teams/
        └── SKILL.md
```

---

## この名前の理由

`damascus`、`sketch`、`forge`はこのマーケットプレイスの既存のメタファー系ブランド名です。`grimoire`はその家族に馴染む名前 — パターンを収めた書、常に棚にあり、必要な時に取り出すもの。`common-skills`や`reusable-patterns`といった直接的な名前も候補でしたが、姉妹プラグインとの命名一貫性を考慮して`grimoire`に決まりました。

代償は：メタファー名は説明文があって初めて役立つこと。このページがその役割を果たします。

---

## ライセンス

MIT
