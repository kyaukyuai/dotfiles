# dotfiles

[chezmoi](https://chezmoi.io) で管理する個人 dotfiles。

## 適用

```bash
brew install chezmoi
chezmoi init --apply <your-github-username>   # 例: chezmoi init --apply kyaukyuai
```

## 含むもの

- **shell**: `.zshrc`（starship + zsh）
- **git**: `.gitconfig`（alias 多数・ghq）／ `~/.config/git/ignore`
- **vim**: `.vimrc`
- **~/.config**: `aerospace`（タイリングWM）/ `borders`（JankyBorders）/ `karabiner` / `sketchybar`（ステータスバー）/ `starship` / `zed`（settings）

## 含まないもの（重要）

- **機密は含まれません**。API キー等は `~/.config/zsh/secrets.zsh`（chmod 600・git管理外）に分離し、`.zshrc` から `source` します。
- `gh` / `gcloud` / `github-copilot` 等の認証ディレクトリは `.chezmoiignore` 済みで版管理対象外です。

## ライセンス

MIT（`LICENSE` 参照）。

## ローカル identity（任意）

公開既定は `email = *@users.noreply.github.com` / `gpgsign = false`。自分のマシンで実名メール・GPG 署名を使うには、git 管理外（`.chezmoiignore` 済み）の次のファイルを作成する。`.gitconfig` 末尾の `[include]` が存在すれば読み込む。

```ini
# ~/.config/git/identity.local
[user]
	name = Your Name
	email = you@example.com
	signingkey = YOUR_GPG_KEY_ID
[commit]
	gpgsign = true
```
