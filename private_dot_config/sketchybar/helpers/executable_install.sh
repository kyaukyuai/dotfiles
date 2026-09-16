#!/usr/bin/env bash
# sketchybar 設定の依存を一括インストールする（2026-09 時点の手順）
# 元の SoichiroYamane 版から、廃止された homebrew/cask-fonts tap と
# macOS 15.4 以降で動かない nowplaying-cli を置き換えている。
set -euo pipefail

# Packages
brew tap FelixKratz/formulae
brew install sketchybar lua switchaudio-osx

# 再生中メディア取得（MediaRemote 制限の回避。/usr/bin/perl 経由でアクセスする）
brew tap ungive/media-control
brew install media-control

# Fonts（font-sf-* は .pkg のため sudo が必要。sudo が使えない場合は
#   brew fetch --cask font-sf-mono → dmg 内の pkg を pkgutil --expand-full で展開し
#   *.otf を ~/Library/Fonts へコピーする）
brew install --cask sf-symbols
brew install --cask font-sf-mono font-sf-pro || true

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/sketchybar-app-font.ttf \
  -o "$HOME/Library/Fonts/sketchybar-app-font.ttf"
# sketchybar-app-font-bg はリリース資産が削除済み（リポジトリはアーカイブ）なので
# ソースからビルドする。フォントと helpers/icon_map.lua を同時に更新する。
if command -v pnpm >/dev/null 2>&1; then
  tmp=$(mktemp -d)
  git clone --depth 1 https://github.com/SoichiroYamane/sketchybar-app-font-bg.git "$tmp/fontbg"
  (cd "$tmp/fontbg" && pnpm install --silent && pnpm run build)
  cp "$tmp/fontbg/public/dist/sketchybar-app-font-bg.ttf" "$HOME/Library/Fonts/sketchybar-app-font-bg.ttf"
  cp "$tmp/fontbg/public/dist/icon_map.lua" "$HOME/.config/sketchybar/helpers/icon_map.lua"
  rm -rf "$tmp"
else
  echo "pnpm が無いため sketchybar-app-font-bg をビルドできません (brew install pnpm)" >&2
fi

# SbarLua（Lua から sketchybar を操作するモジュール）
tmp=$(mktemp -d)
git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$tmp/SbarLua"
(cd "$tmp/SbarLua" && make install)
rm -rf "$tmp"

# 自動起動（launchd）。AeroSpace の after-startup-command ではなく brew services で常駐させる
brew services start sketchybar

cat <<'MSG'
残りの手動設定:
  * システム設定 > プライバシーとセキュリティ > 画面収録とシステムオーディオ録音 に
    /opt/homebrew/opt/sketchybar/bin/sketchybar を追加してから sketchybar を再起動
    （メニューバー項目の取得に必要）
  * aerospace.toml に exec-on-workspace-change で aerospace_workspace_change を発火する設定を入れる
MSG
