#!/bin/zsh
set -euo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  print -u2 -- "エラー：Gitリポジトリ内で実行してください。"
  exit 1
fi

cd "$REPO_ROOT"

cat > 003-hotfix.md <<'MARKDOWN'
# 緊急対応：hotfix

## 運用方針

- `main`から`hotfix/issue1`などの作業ブランチを作成する。
- 修正内容を`main`にマージし、緊急リリースする。
- その後、同じhotfixブランチを`dev`にもマージする。
- 両方へのマージ・pushと動作確認が完了した後、hotfixブランチを削除する。
- `main`と`dev`は継続利用する。

## 運用フロー

```mermaid
gitGraph
    commit id: "初期状態"
    branch dev
    checkout main
    branch hotfix/issue1
    commit id: "緊急の不具合を修正"
    checkout main
    merge hotfix/issue1 id: "hotfix/issue1をmainにマージ：緊急リリース"
    checkout dev
    merge hotfix/issue1 id: "hotfix/issue1をdevにマージ"
```

図は分岐・マージの関係を示す模式図であり、ブランチ削除操作は表現していない。

## 操作手順

`001-setup.md`の初期設定を実施済みであり、
`main`と`dev`がローカルに存在することを前提とする。

```bash
# mainブランチにいること、未コミットの変更がないことを確認
git status

# 緊急対応用の作業ブランチを作成
git switch -c hotfix/issue1

# ここでコード変更・動作確認を行う

# コミット・push
git add .
git commit -m "緊急の不具合を修正"
git push -u origin hotfix/issue1

# mainへのマージ前にログを確認
git switch main
git log --graph --oneline --decorate main..hotfix/issue1

# 内容を確認後、mainへ統合・緊急リリース
git merge hotfix/issue1 \
  -m "hotfix/issue1をmainにマージ：緊急の不具合を修正"
git push -u origin main

# mainへの統合後、全体ログを確認
git log --graph --oneline --decorate --all

# ここで本番環境への反映・動作確認を行う

# devへのマージ前にログを確認
git switch dev
git log --graph --oneline --decorate dev..hotfix/issue1

# 同じhotfixブランチをdevへ統合
git merge hotfix/issue1 \
  -m "hotfix/issue1をdevにマージ：緊急修正を開発環境に反映"
git push -u origin dev

# ここでpreview版の動作確認を行う

# 両方へのマージ・push・動作確認の完了後、作業ブランチを削除
git branch -d hotfix/issue1
git push origin --delete hotfix/issue1

# 全体ログを確認
git log --graph --oneline --decorate --all
```

## 運用上の注意

- 上記は段階ごとに確認しながら実行する手順であり、一括実行しない。
- 競合やエラーが発生した場合は中断し、解消・確認後に次へ進む。
- `main`へのpush後、本番環境への反映を確認してから`dev`への適用を進める。
- `dev`には`main`全体ではなく、今回作成したhotfixブランチを直接マージする。
- hotfixブランチは、`main`への適用直後には削除しない。
- 削除前に、`main`と`dev`の両方への適用が完了していることを確認する。
- 作業ブランチの削除には`-d`を使用し、削除できない場合は理由を確認する。
- `main`と`dev`は削除しない。
MARKDOWN

print -- "003-hotfix.md を生成しました。"

git add .
git commit -m '緊急対応のGit運用手順を作成'