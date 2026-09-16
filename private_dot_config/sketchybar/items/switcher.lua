-- Hammerspoon の 4 列レイアウト (~/.hammerspoon/init.lua) の「切替列（左から 3 番目）」のキーを表示する。
--   * 一覧:        下の SWITCH（init.lua の SWITCH と並び・キーを揃える）
--   * ハイライト:  Hammerspoon が left_column_change (KEY=<key>) を発火する
--   * クリック:    hammerspoon://switch?key=<key> を開いて Hammerspoon 側で切り替える
-- 項目名は space.<key> にして、menus.lua のメニュー表示切替（/space\..*/ を隠す）をそのまま使う。
local colors = require("colors")
local settings = require("settings")
local app_alias = require("helpers.app_alias")

sbar.add("event", "left_column_change")

local SWITCH = {
	{ key = "t", app = "Ghostty" },
	{ key = "e", app = "Zed" },
	{ key = "c", app = "Cursor" },
	{ key = "b", app = "Google Chrome" }, -- 仕事プロフィール
	{ key = "p", app = "Google Chrome" }, -- 個人プロフィール
	{ key = "m", app = "Spark" },
	{ key = "n", app = "Notion" },
	{ key = "g", app = "Grok Bot" },
	{ key = "f", app = "Finder" },
}

local palette = {
	colors.cmap_1,
	colors.cmap_2,
	colors.cmap_3,
	colors.cmap_4,
	colors.cmap_5,
	colors.cmap_6,
	colors.cmap_7,
	colors.cmap_8,
	colors.cmap_9,
	colors.cmap_10,
}

local items = {}
local item_color = {}

for idx, spec in ipairs(SWITCH) do
	local color = palette[((idx - 1) % #palette) + 1]
	item_color[spec.key] = color
	items[spec.key] = sbar.add("item", "space." .. spec.key, {
		icon = {
			font = { family = settings.font.numbers, size = 14 },
			string = spec.key:upper(),
			padding_left = 5,
			padding_right = 0,
			color = color,
			highlight_color = colors.tn_black3,
		},
		label = {
			padding_right = 10,
			padding_left = 3,
			color = color,
			highlight_color = colors.tn_black3,
			font = "sketchybar-app-font-bg:Regular:21.0",
			y_offset = -2,
			string = app_alias.icon_for(spec.app),
		},
		padding_right = 4,
		padding_left = 4,
		background = {
			color = colors.transparent,
			height = 25,
			corner_radius = 6,
			border_width = 0,
			border_color = colors.transparent,
		},
		click_script = "open -g 'hammerspoon://switch?key=" .. spec.key .. "'",
	})
end

sbar.add("bracket", "spaces.bracket", { "/space\\..*/" }, {
	background = {
		color = colors.background,
		border_color = colors.accent3,
		border_width = 2,
	},
})

local function highlight(key)
	for _, spec in ipairs(SWITCH) do
		local selected = (spec.key == key)
		items[spec.key]:set({
			icon = { highlight = selected },
			label = { highlight = selected },
			background = {
				color = selected and item_color[spec.key] or colors.transparent,
				border_color = selected and item_color[spec.key] or colors.transparent,
			},
		})
	end
end

local observer = sbar.add("item", "switcher.observer", { drawing = false, updates = true })
observer:subscribe("left_column_change", function(env)
	highlight(env.KEY or "")
end)

sbar.add("item", { width = 6 })

-- 起動時に Hammerspoon から現在の状態をもらう
sbar.exec("open -g 'hammerspoon://sync'")
