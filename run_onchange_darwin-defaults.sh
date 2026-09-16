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
