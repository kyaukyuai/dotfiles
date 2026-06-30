#!/usr/bin/env bash
# 自分のワークスペースがフォーカスされていれば背景を描画
sid="${NAME#space.}"
if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" background.drawing=on
else
  sketchybar --set "$NAME" background.drawing=off
fi
