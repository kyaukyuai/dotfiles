-- 次の予定（icalBuddy）: 直近1件を「HH:MM - HH:MM タイトル」で右側に表示する。
-- 予定が無いときは項目ごと隠す。初回実行時に sketchybar へのカレンダーアクセス許可が求められる。
local settings = require("settings")
local colors = require("colors")

local CMD = "/opt/homebrew/bin/icalBuddy -n -li 1 -b '' -nc -eep 'notes,url,location,attendees' "
	.. "-po 'datetime,title' -df '' -tf '%H:%M' eventsToday+1 2>/dev/null | tr '\\n' ' '"

local next_event = sbar.add("item", "next_event", {
	icon = {
		drawing = "off",
	},
	label = {
		color = colors.tn_green,
		font = { family = settings.font.numbers, size = 12 },
		padding_left = 8,
		padding_right = 8,
		max_chars = 28,
	},
	position = "right",
	update_freq = 60,
	background = {
		color = colors.tn_black3,
		height = 25,
		corner_radius = 6,
		border_width = 1,
		border_color = colors.tn_green,
	},
})

next_event:subscribe({ "forced", "routine", "system_woke" }, function(_)
	sbar.exec(CMD, function(out)
		local text = (out or ""):gsub("%s+$", ""):gsub("^%s+", "")
		if text == "" then
			next_event:set({ drawing = false })
		else
			next_event:set({ drawing = true, label = text })
		end
	end)
end)

sbar.add("item", { position = "right", width = 6 })
