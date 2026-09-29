#!/bin/bash
# macOS の defaults をまとめて適用する（内容が変わったときだけ chezmoi apply で再実行される）
[ "$(uname)" = "Darwin" ] || exit 0
set -eu

# キーリピート: 最速付近（システム設定の UI では到達できない値）。再ログイン後に有効
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
# 長押しでアクセント記号候補を出さず、素直にリピートさせる（vim キーバインド向け）
defaults write -g ApplePressAndHoldEnabled -bool false

# Dock / メニューバーは自動非表示（AeroSpace + sketchybar 前提）
defaults write com.apple.dock autohide -bool true
defaults write -g _HIHideMenuBar -bool true
# defaults に書くだけでは再ログインまで反映されず、レイアウト上は隠れているのに
# メニューバーが描画されたまま sketchybar と重なる半端な状態になる。
# System Events 経由で設定すると即時に反映される（初回は「オートメーション」の許可ダイアログが出る）。
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true' >/dev/null 2>&1 || true
osascript -e 'tell application "System Events" to set autohide of dock preferences to true' >/dev/null 2>&1 || true

# Mission Control（AeroSpace 公式ガイド推奨）
#   expose-group-apps: ウィンドウをアプリごとにグループ化（多数ウィンドウの縮小表示を軽減）
#   spans-displays:    「ディスプレイごとに個別の操作スペース」を無効化（複数モニターでのフォーカス不安定を回避。再ログインで有効）
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.spaces spans-displays -bool true
killall Dock >/dev/null 2>&1 || true

# AltTab: 現在のスペースのウィンドウのみ表示、ログイン時に起動
defaults write com.lwouis.alt-tab-macos spacesToShow -string "1"
defaults write com.lwouis.alt-tab-macos startAtLogin -string "true"

# ---- Finder ----
# 新規ウィンドウはホームディレクトリで開く（既定は「最近の項目」）
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
# 既定はリスト表示（Nlsv: List / icnv: Icon / clmv: Column / glyv: Gallery）
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# パスバー・ステータスバーを常時表示（現在地と空き容量が一目で分かる）
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# ウィンドウタイトルにフルパスを表示
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# フォルダをファイルより先に並べる
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# 検索の既定スコープを「このMac」ではなく「現在のフォルダ」にする
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# すべての拡張子を表示し、拡張子変更時の警告は出さない
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Finder に「終了」メニュー（Cmd+Q）を追加。ウィンドウをまとめて閉じたいときに便利
defaults write com.apple.finder QuitMenuItem -bool true
# ネットワーク/USB ドライブに .DS_Store を作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# ~/Library をサイドバー/ホームから辿れるように表示
chflags nohidden "${HOME}/Library"
# 保存/開くダイアログは最初から展開表示（ファイル名だけの小さいダイアログにしない）
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
# Finder の設定を反映（自動で再起動する）
killall Finder 2>/dev/null || true
