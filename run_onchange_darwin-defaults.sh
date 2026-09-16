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

# AltTab: 現在のスペースのウィンドウのみ表示、ログイン時に起動
defaults write com.lwouis.alt-tab-macos spacesToShow -string "1"
defaults write com.lwouis.alt-tab-macos startAtLogin -string "true"
