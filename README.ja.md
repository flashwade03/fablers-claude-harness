<div align="center">

# fablers

**プロンプティングをやめて、ハーネスを装着しよう。**

実証済みのワークフローを再利用可能なプラグインにパッケージ化したClaude Codeマーケットプレイス。
設計方法論、ドキュメント鍛造、エージェンティックRAG — すべてを一箇所で。

[![Claude Code Marketplace](https://img.shields.io/badge/Claude_Code-Marketplace-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.10.0-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## プラグイン

### `vibe-architecture` — 設計方法論 & スキル抽出

実証済みの設計方法論をスキルにエンコードし、Claudeが必要な時にロードします。場当たり的なプロンプティングの代わりに、実際に機能する構造化されたワークフロー。

| スキル | 内容 |
|--------|------|
| **vibe-design** | ラフなアイデアを必要十分な設計に。決定 + 制約 + マイルストーン、疑似コードではない。 |
| **design-review** | 6軸評価で設計ドキュメントをスコアリング（S〜Fグレード、0-100点）。FAIL1つでグレードC制限。 |
| **sketch-team** | Agent Teams ワークフローで**具体的なマルチドメイン設計**: Specialist Designer 1–3名（data-model / api-surface / protocol など、Lead がタスク別に決定）が却下された代替案のインライン記録を含む具体的アーティファクトを生成、Planner がドメイン横断整合性チェック後に合成、Reviewer 2名が具体化フレンドリーな6軸ルーブリックで判定、承認までループ。 |
| **session-skill-extractor** | 会話を分析して再利用可能なパターンを抽出。スキル、CLAUDE.md、hookify、memoryにルーティング。 |

```
> /sketch                          # 設計を開始（単一エージェントQ&A）
> /sketch-team <タスク>             # Agent Teams: 設計 + レビュー束ね、自動イテレーション
> 設計をレビューして                   # 設計レビュー
> 会話からスキルを抽出して              # セッションからスキル抽出
```

---

### `damascus` — 反復的マルチLLMレビューでドキュメントを鍛造

> *ダマスカス鋼のように、ドキュメントは繰り返し鍛えることで強くなる。*

複数のLLMを活用した反復レビューループでドキュメントを精錬します。実装計画や技術ドキュメントを作成し、Claude、Gemini、OpenAIが並列でレビューした後、承認されるまで反復。

```
> /forge <タスク説明>               # 単一レビュアー鍛造
> /forge-team <タスク説明>          # マルチLLMチームレビュー
> /forge-plan <タスク説明>          # プランのみ
> /forge-doc <タスク説明>           # ドキュメントのみ
```

---

### `fablers-agentic-rag` — ドキュメントに質問。引用付きの回答を取得。

エージェンティックRAGパイプライン — クエリ分析、ハイブリッド検索（ベクトル + BM25）、CRAG検証、引用付き回答合成 — すべてClaudeエージェントがオーケストレーション。PDF、テキスト、Markdownに対応。

```
> /ingest <ファイル>                # ドキュメントのインデックス作成
> /rag-ask <質問>                  # 引用付きクエリ
> /rag-search <クエリ>              # 生の検索
```

---

### `grimoire` — 汎用・再利用可能スキル集

単一目的プラグインではありません。特定のコマンドやワークフローに紐付かないClaude Code スキルの成長するコレクション — どのプラグインが有効でも、状況に応じてClaudeが取り出す種類のパターンです。`grimoire`という名前は「再利用パターンの書」というメタファーであり、今読んでいるこの説明がそのメタファーの不親切さを補っています。

| スキル | 内容 |
|--------|------|
| **agent-teams** | 単一エージェントが複数のペルソナを演じる"偽物のチーム"ではなく、本物のClaude Code agent team（TeamCreate + SendMessage）を起動してdebate / review / implementation を実行。cross-challenge プロンプトパターン、worked example、`/forge-team`との境界明示を含む。 |

```
> エージェントチームを作って           # 本物のエージェントチームをスポーン
> チームで議論して                   # 構造化されたcross-agent debate
```

---

## クイックスタート

```bash
# マーケットプレイスを登録
/plugin marketplace add flashwade03/fablers-claude-plugins

# 個別プラグインをインストール
/plugin install vibe-architecture@fablers
/plugin install damascus@fablers
/plugin install fablers-agentic-rag@fablers
/plugin install grimoire@fablers
```

---

## プロジェクト構造

```
my-claude-harness/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── vibe-architecture/         # 設計方法論
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/
│   │   └── skills/
│   │       ├── vibe-design/
│   │       ├── design-review/
│   │       └── session-skill-extractor/
│   ├── damascus/                       # ドキュメント鍛造
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   ├── commands/
│   │   ├── hooks/
│   │   ├── scripts/
│   │   └── skills/
│   ├── fablers-agentic-rag/            # エージェンティックRAG
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   ├── commands/
│   │   ├── hooks/
│   │   ├── scripts/
│   │   └── skills/
│   └── grimoire/                       # 汎用・再利用可能スキル集
│       ├── .claude-plugin/plugin.json
│       └── skills/
│           └── agent-teams/
```

---

## フィロソフィー

1. **決定であり、実装ではない** — 設計ドキュメントは*何を*と*なぜ*を記録する。*どうやって*は決して含まない
2. **段階的開示** — コアワークフローが先にロードされ、詳細は必要な時だけ
3. **複雑さは稼ぐもの** — シンプルなパターンはシンプルに。スキルは十分に複雑な場合のみ作成

---

## ライセンス

MIT
