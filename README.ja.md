<div align="center">

# fablers-claude-harness

**プロンプティングをやめて、ハーネスを装着しよう。**

実証済みの設計方法論を再利用可能なスキルにエンコードしたClaude Codeプラグイン。
場当たり的なプロンプティングの代わりに、実際に機能する構造化されたワークフロー。

[![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.2.6-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## なぜ？

AIコーディングは強力ですが、構造なしに使うとカオスです：
- 過剰設計 — 誰も読まない8,000行の設計ドキュメント
- 過少設計 — ゴミのような実装結果
- 毎セッション、同じワークフローをゼロから再構築

**fablers-claude-harness**は、実証済みの方法論をスキルとしてパッケージ化し、Claudeが必要な時にロードします。

---

## スキル

### `vibe-design` — 必要な分だけ設計する

> *"設計 = 決定 + 制約 + マイルストーン。疑似コードではない。"*

バイブコーディングに最適なレベルの設計ドキュメントを作成します。8,000行の設計ドキュメントはもう終わり。

| ステップ | 内容 |
|---------|------|
| スコープチェック | 設計ドキュメントは必要か？不要ならすぐ実装。 |
| ユーザー対話 | 質問は1つずつ。自由回答より選択肢優先。 |
| 決定成熟度 | 確定した決定にのみ根拠。候補はリストのみ。 |
| ドメインチェックリスト | 見落とし決定なく、漏れなく。 |
| 作成 & 検証 | 約200-300行。すべての行が決定であり、実装ではない。 |

```
> 設計して
> アーキテクチャを決めて
> design a feature
```

---

### `design-review` — 6軸評価、S〜Fグレード

> *"疑似コードがあれば、それは設計ドキュメントではない。"*

実際の過剰設計失敗事例から導出した6つの軸で設計ドキュメントを評価。グレード、スコア、具体的な修正方法を出力。

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

**FAIL**が1つでもあればグレードはCに制限。根本的な問題のある設計は通過不可。

```
> 設計をレビューして
> 設計を評価して
> review my design
```

---

### `session-skill-extractor` — 会話をスキルに変換

> *"最高のワークフローがセッションと共に消えてはならない。"*

現在の会話を分析して、保存する価値のあるパターンを見つけ、承認されればスキルとして作成します。

**動作方式：**

1. 会話全体を6つのシグナルタイプでスキャン
2. 再利用性、複雑さ、独自性で候補をスコアリング
3. 提案を提示 — ユーザーが選択
4. 適切な構造、トリガーフレーズ、参照ファイルと共にスキルを作成
5. 完了前に構造を検証

複雑さが低いパターンはスキルの代わりにCLAUDE.mdルールにリダイレクト。スキルの肥大化を防止。

```
> 会話からスキルを抽出して
> このセッションでスキルにできるものはある？
> extract skill from conversation
```

---

## クイックスタート

```bash
# マーケットプレイスからインストール
claude plugin add flashwade03/fablers-claude-harness

# またはローカルで実行
claude --plugin-dir /path/to/fablers-claude-harness
```

---

## プロジェクト構造

```
fablers-claude-harness/
├── .claude-plugin/
│   ├── plugin.json              # プラグインマニフェスト
│   └── marketplace.json         # マーケットプレイスメタデータ
└── skills/
    ├── vibe-design/             # 設計方法論
    │   ├── SKILL.md
    │   └── references/
    │       ├── principles.md
    │       ├── anti-patterns.md
    │       └── domain-web-service.md
    ├── design-review/           # 6軸レビュースコアリング
    │   ├── SKILL.md
    │   ├── references/
    │   └── examples/
    └── session-skill-extractor/ # 会話 → スキル変換
        ├── SKILL.md
        └── references/
            ├── analysis-criteria.md
            └── transformation-guide.md
```

---

## フィロソフィー

このプラグインは3つの原則に従います：

1. **決定であり、実装ではない** — 設計ドキュメントは*何を*と*なぜ*を記録する。*どうやって*は決して含まない
2. **段階的開示** — コアワークフローが先にロードされ、詳細は必要な時だけ
3. **複雑さは稼ぐもの** — シンプルなパターンはシンプルに。スキルは十分に複雑な場合のみ作成

---

## ライセンス

MIT
