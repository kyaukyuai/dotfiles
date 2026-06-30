#!/usr/bin/env bash
batt=$(pmset -g batt)
pct=$(echo "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
[ -z "$pct" ] && exit 0
if echo "$batt" | grep -q 'AC Power'; then
  sketchybar --set "$NAME" label="⚡${pct}%"
else
  sketchybar --set "$NAME" label="${pct}%"
fi
