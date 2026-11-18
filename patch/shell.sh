#!/bin/zsh
set -euo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  print -u2 -- "エラー：Gitリポジトリ内で実行してください。"
  exit 1
fi

cd "$REPO_ROOT"

cat > 001-setup.md <<'MARKDOWN'
# Git初期設定

## マージ設定

各開発者が、リポジトリのclone後に実行する。

```bash
git config --local merge.ff false
git config --local --get merge.ff
```

設定値が`false`であることを確認する。
以降は、`git merge`の`--no-ff`を省略する。

この設定はローカルリポジトリに適用され、pushでは共有されない。

## ブランチ構成

| ブランチ | 用途 |
| --- | --- |
| `main` | リリース用。本番環境。 |
| `dev` | preview版。開発環境としてのメインブランチ。 |
| `feature/*` | 機能追加の作業ブランチ。 |
| `hotfix/*` | 緊急対応の作業ブランチ。 |
| `refactor/*` | リファクタリング用の作業ブランチ。 |

`main`と`dev`は継続利用する。
`feature/*`は`dev`から分岐し、統合・確認後に削除する。

`hotfix/*`・`refactor/*`の詳細手順は別途定める。

## コミットメッセージ

- 通常のコミット：ブランチ名を含めず、変更内容を簡潔な日本語で記載する。
- マージコミット：マージ元・マージ先のブランチ名と、統合内容を記載する。

```bash
git commit -m "検索機能を追加"

git merge feature/add-function \
  -m "feature/add-functionをdevにマージ：検索機能を追加"

git merge dev \
  -m "devをmainにマージ：検索機能をリリース"
```
MARKDOWN

cat > 002-basic-operation.md <<'MARKDOWN'
# 基本操作：機能追加からリリースまで

## 運用フロー

```mermaid
gitGraph
    commit id: "初期状態"
    branch dev
    branch feature/add-function
    commit id: "検索機能を追加"
    checkout dev
    merge feature/add-function id: "feature/add-functionをdevにマージ"
    checkout main
    merge dev id: "devをmainにマージ"
```

図は分岐・マージの関係を示す模式図であり、ブランチ削除操作は表現していない。

## 操作手順

`001-setup.md`の初期設定を実施済みであることを前提とする。
以下は、`dev`を初めて作成する場合の手順である。

```bash
# mainブランチにいること、未コミットの変更がないことを確認
git status

# devの準備（作成済みの場合は git switch dev に置き換える）
git switch -c dev

# 作業ブランチの作成
git switch -c feature/add-function

# ここでコード変更・動作確認を行う

# コミット・push
git add .
git commit -m "検索機能を追加"
git push -u origin feature/add-function

# マージ前のログ確認
git switch dev
git log --graph --oneline --decorate dev..feature/add-function

# 内容を確認後、devへ統合
git merge feature/add-function \
  -m "feature/add-functionをdevにマージ：検索機能を追加"
git push -u origin dev

# ここでpreview版の動作確認を行う

# マージ・push・動作確認の完了後、作業ブランチを削除
git branch -d feature/add-function
git push origin --delete feature/add-function

# mainへ統合・リリース
git switch main
git merge dev \
  -m "devをmainにマージ：検索機能をリリース"
git push -u origin main

# 全体ログを確認
git log --graph --oneline --decorate --all
```

## 運用上の注意

- 上記は段階ごとに確認しながら実行する手順であり、一括実行しない。
- 競合やエラーが発生した場合は中断し、解消・確認後に次へ進む。
- 作業ブランチの削除には`-d`を使用し、削除できない場合は理由を確認する。
- `main`と`dev`は削除しない。
- 作業ブランチの削除後も、統合済みのコミットとマージの構造は残る。
- 削除したブランチ名は、マージコミットのメッセージで確認する。
- ブランチ作成操作そのものや作成日時を記録するものではない。
MARKDOWN

print -- "001-setup.md と 002-basic-operation.md を生成しました。"

git add .
git commit -m 'Git初期設定と基本操作のドキュメントを作成'