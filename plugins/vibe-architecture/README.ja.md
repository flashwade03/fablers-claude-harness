<div align="center">

# vibe-architecture

**決定が先。実装はAIに。**

Vibe coding設計方法論をClaude Codeスキルとしてラップ — ラフなアイデアを構造化されたスペック（決定・制約・マイルストーン、**疑似コードは決して含まない**）に変換し、6軸ルーブリックでスコアリングし、抽象スペックだけでは不十分な場合はAgent Teamsでマルチドメイン具体設計までスケール。セッションから再利用可能なパターンをスキルに逆抽出する機能も含みます。

[![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet?style=for-the-badge)](https://claude.ai)
[![Version](https://img.shields.io/badge/version-0.8.3-blue?style=for-the-badge)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](../../LICENSE)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

</div>

---

## スキル

### vibe-design

ラフなアイデアを必要十分な設計スペックに。アイデア探索から構造化された設計ドキュメントまで全工程をカバー。

- **Scope check**: そもそも設計ドキュメントが必要か？不要ならスキップして実装。
- **1-question-at-a-time 対話**: 2-3個のアプローチをトレードオフとともに提示。
- **Decision maturity**: 確定した決定には根拠を。候補はbulletのまま。
- **Output**: 決定と制約で構成される200-300行、疑似コードなし。

```
> /sketch                 # 推奨 — 常にスキルをロード
> 設計して                  # 自然言語トリガーは安定して発動しない場合あり
> アーキテクチャを立てて
```

自然言語の表現だけではスキルが一貫して発動しないことがあります — 広範な設計会話はClaudeが直接処理する場合が多いです。方法論を明示的にロードしたい時は`/sketch`を使用してください。

### design-review

設計ドキュメントを6軸のvibe codingルーブリックで採点。Grade (S~F)、Score (0-100)、具体的なフィードバックを出力。

| 軸 | 検査内容 |
|-----|---------|
| Decision Purity | すべての文が決定であり実装ではない |
| Rationale Presence | すべての決定に根拠が明示されている |
| Decision Maturity | 確定 vs 候補の決定が明確に区別されている |
| Context Budget | 200-300行内に収まる |
| Constraint Quality | 境界であって処方ではない |
| CLAUDE.md Alignment | 設計ドキュメントがリンクされており重複していない |

いずれかの軸でFAILが1つでもあればGradeはCに制限されます。

```
> 設計をレビューして
> score this design
> design quality check
```

### sketch-team

Agent Teamsで**具体的なマルチドメイン設計**を生成。`/sketch`（vibe-design単独）がAIが後で埋められるよう決定を抽象のままにするのに対し、`/sketch-team`は意図的に具体化します — インターフェース、データ形状、シーケンス図。一部のドメインでは具体的アーティファクト*そのもの*が決定になるためです（APIコントラクト、メッセージプロトコル、カスケード型のデータモデルなど）。

Leadがユーザー対話を管理（vibe-design Step 0.5–1.5）、タスクの自然なドメイン分解に基づいて1–3名の**Specialist Designer**を選択（例：`data-model`、`api-surface`、`protocol`）、その後チームが自律的に実行：

- **Specialistの構成はタスク別にLeadが決定**: 同じ問題の「アプローチ」群ではない — 各Designerはチームの一ドメイン専門家
- **2-pass 整合性**: 予備ドメインアーティファクト → Plannerがpeerサマリー + クロスドメイン衝突を構築 → 洗練されたアーティファクト → 合成。Specialistが検討した却下代替案は `Alternative considered: X — rejected because Y` の形式でインラインに残ります。
- **単一writer（Scribe）**: design.mdと.review.md — 役割境界が明確、ファイル競合なし
- **具体化フレンドリーな7軸ルーブリック**: Specification Productivity / Rationale Presence / Decision Maturity / Failure Coverage / Specialist Coherence / Constraint Quality / CLAUDE.md Alignment. load-bearing な具体的アーティファクト（シグネチャ、スキーマ、シーケンス図）は許容するが、装飾的な疑似コードは拒否。Failure Coverage はクリティカルな失敗モードが処理決定とともに明示されているかをチェック。
- **厳格な判定 + max_rounds 上限**: いずれかの軸でFAIL → NEEDS_REVISION；デフォルト上限3；到達時はユーザーにエスカレーション

**前提条件**: `.claude/settings.json`に以下が必要：
```json
{
  "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" },
  "teammateMode": "tmux"
}
```
`teammateMode: "tmux"`はオプションですが推奨 — チームメイトごとにsplit paneが開かれ、作業を観察できます。

```
> /sketch-team リトライと優先度を処理するジョブキューを設計して
> /sketch-team -n 5 マルチテナントデータ分離のアーキテクチャ
> /sketch-team -o docs/features/notifications.md 通知システムを設計して
```

**いつどちらを使うか**: 実装を開いておくことが正しい初期段階では`/sketch`。具体化そのものが決定を決める設計（APIコントラクト、メッセージプロトコル、マルチドメインデータ形状）には`/sketch-team`。

### session-skill-extractor

現在の会話を分析して再利用可能なパターンを抽出。各発見を最適な行き先にルーティング：

- **反復可能なワークフロー** → 新スキル
- **明示的なルール** → CLAUDE.md
- **修正** → hookifyルール
- **ドメイン知識** → memory

```
> 会話からスキルを抽出して
> セッション振り返り
> turn this conversation into skills
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `/sketch` | vibe-designを対話的に開始（単一エージェントQ&A） |
| `/sketch-team` | Agent Teams ワークフロー — 設計 + レビュー束ね、承認またはmax_roundsまで自動イテレーション |
