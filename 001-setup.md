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

| ブランチ     | 用途                                        |
|--------------|---------------------------------------------|
| `main`       | リリース用。本番環境。                      |
| `dev`        | preview版。開発環境としてのメインブランチ。 |
| `feature/*`  | 機能追加の作業ブランチ。                    |
| `hotfix/*`   | 緊急対応の作業ブランチ。                    |
| `refactor/*` | リファクタリング用の作業ブランチ。          |

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
