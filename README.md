# dotfiles

[chezmoi](https://chezmoi.io) で管理する個人 dotfiles。

## 適用

```bash
brew install chezmoi
chezmoi init --apply <your-github-username>   # 例: chezmoi init --apply kyaukyuai
brew bundle --global                          # ~/.Brewfile から Homebrew パッケージを復元
```

`chezmoi apply` 時に `run_onchange_darwin-defaults.sh` が macOS の defaults（キーリピート、Dock/メニューバー自動非表示、AltTab）を適用する。

## 含むもの

- **shell**: `.zshrc`（starship + zsh）
- **git**: `.gitconfig`（alias 多数・ghq）／ `~/.config/git/ignore`
- **vim**: `.vimrc`
- **~/.hammerspoon**: `init.lua`（ウルトラワイド向け 4 列固定レイアウト。Codex / Claude / 切替 / Slack の順。3 列目を alt+キーで切替。`ultrawide = true` のマシンのみ）
- **~/.config**: `aerospace`（タイリングWM。`ultrawide = true` のマシンではログイン時に起動しない）/ `borders`（JankyBorders）/ `ghostty`（ターミナル）/ `karabiner` / `sketchybar`（ステータスバー、SbarLua + AeroSpace 連携）/ `starship` / `zed`（settings）
- **Homebrew**: `.Brewfile`（日常的に使うツールを厳選したリスト。`brew bundle dump` の全量ではない。追加したいものは手で追記する）

## マシン別の切り替え（`ultrawide`）

`chezmoi init` 時に「ウルトラワイド運用にするか」を一度だけ尋ね、`~/.config/chezmoi/chezmoi.toml` の `[data] ultrawide` に保存する（既定は `false`、`.chezmoidata.toml`）。`true` のマシンでは Hammerspoon の 4 列レイアウトと sketchybar の切替列表示を配り、AeroSpace はログイン時に起動しない。後から変えるときは `chezmoi.toml` を編集して `chezmoi apply`。

```toml
# ~/.config/chezmoi/chezmoi.toml
[data]
    ultrawide = true
```

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
