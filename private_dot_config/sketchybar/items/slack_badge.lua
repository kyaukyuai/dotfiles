-- Slack 未読バッジ: Dock のバッジ（StatusLabel）を lsappinfo で読んで右側に表示する。
-- バッジ無しのときは項目ごと隠す。数字のほか「•」（メンション無し未読）も表示する。
local settings = require("settings")
local colors = require("colors")
local app_alias = require("helpers.app_alias")

local CMD = "lsappinfo info -only StatusLabel $(lsappinfo find LSDisplayName=Slack) 2>/dev/null"

local slack_badge = sbar.add("item", "slack_badge", {
	icon = {
		font = "sketchybar-app-font-bg:Regular:19.0",
		string = app_alias.icon_for("Slack"),
		color = colors.tn_red,
		padding_left = 6,
		padding_right = 0,
		y_offset = -1,
	},
	label = {
		color = colors.tn_red,
		font = { family = settings.font.numbers, size = 12 },
		padding_left = 3,
		padding_right = 8,
	},
	position = "right",
	update_freq = 30,
	background = {
		color = colors.tn_black3,
		height = 25,
		corner_radius = 6,
		border_width = 1,
		border_color = colors.tn_red,
	},
})

slack_badge:subscribe({ "forced", "routine", "system_woke" }, function(_)
	sbar.exec(CMD, function(out)
		local badge = (out or ""):match('"label"="([^"]*)"')
		if badge == nil or badge == "" then
			slack_badge:set({ drawing = false })
		else
			slack_badge:set({ drawing = true, label = badge })
		end
	end)
end)

sbar.add("item", { position = "right", width = 6 })
