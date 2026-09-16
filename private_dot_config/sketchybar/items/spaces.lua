-- AeroSpace のワークスペースを表示する。
-- 元の SoichiroYamane 版は macOS の space + yabai 前提だったので、AeroSpace 用に書き換えている。
--   * ワークスペース一覧:      aerospace list-workspaces --all
--   * フォーカス変更イベント:  aerospace.toml の exec-on-workspace-change が
--                              aerospace_workspace_change を発火
--   * 各ワークスペースのアプリ: aerospace list-windows --all --format '%{workspace}|%{app-name}'
-- 空のワークスペースは非表示にし、ウィンドウがあるもの + フォーカス中のものだけ並べる。
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_alias = require("helpers.app_alias")

sbar.add("event", "aerospace_workspace_change")

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

-- 起動時にワークスペース一覧を同期的に取得（AeroSpace 未起動なら 1..9 で代替）
local order = {}
do
	local handle = io.popen("aerospace list-workspaces --all 2>/dev/null")
	if handle then
		for line in handle:lines() do
			if line ~= "" then
				table.insert(order, line)
			end
		end
		handle:close()
	end
	if #order == 0 then
		for i = 1, 9 do
			table.insert(order, tostring(i))
		end
	end
end

local spaces = {}
local space_color = {}

for idx, name in ipairs(order) do
	local color = palette[((idx - 1) % #palette) + 1]
	space_color[name] = color

	local space = sbar.add("item", "space." .. name, {
		drawing = false,
		icon = {
			font = {
				family = settings.font.numbers,
				size = 14,
			},
			string = name,
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
			string = "—",
		},
		padding_right = 4,
		padding_left = 4,
		background = {
			color = colors.transparent,
			height = 22,
			border_width = 0,
			border_color = colors.transparent,
		},
		click_script = "aerospace workspace " .. name,
	})

	spaces[name] = space
end

-- ワークスペース群を囲う枠（正規表現でまとめて指定）
sbar.add("bracket", "spaces.bracket", { "/space\\..*/" }, {
	background = {
		color = colors.background,
		border_color = colors.accent3,
		border_width = 2,
	},
})

local function apps_to_icon_line(apps)
	if apps == nil then
		return "—"
	end
	local names = {}
	for app in pairs(apps) do
		table.insert(names, app)
	end
	table.sort(names)
	local line = ""
	for _, app in ipairs(names) do
		line = line .. utf8.char(0x202F) .. app_alias.icon_for(app)
	end
	return line
end

local function menus_are_shown()
	local ok, res = pcall(function()
		return sbar.query("menu.1")
	end)
	return ok and res and res.geometry and res.geometry.drawing == "on"
end

-- AeroSpace の状態を問い合わせて全ワークスペース表示を更新する
local function update_spaces()
	sbar.exec(
		"aerospace list-workspaces --focused 2>/dev/null; echo '---'; "
			.. "aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null",
		function(out)
			local focused = nil
			local apps_by_ws = {}
			local section = 1
			for line in tostring(out):gmatch("[^\r\n]+") do
				if line == "---" then
					section = 2
				elseif section == 1 then
					focused = line
				else
					local ws, app = line:match("^([^|]+)|(.*)$")
					if ws then
						apps_by_ws[ws] = apps_by_ws[ws] or {}
						apps_by_ws[ws][app] = true
					end
				end
			end

			local hide_all = menus_are_shown()

			for _, name in ipairs(order) do
				local space = spaces[name]
				local selected = (name == focused)
				local has_windows = apps_by_ws[name] ~= nil
				space:set({
					drawing = (not hide_all) and (has_windows or selected),
					icon = { highlight = selected },
					label = { string = apps_to_icon_line(apps_by_ws[name]), highlight = selected },
					background = {
						height = 25,
						color = selected and space_color[name] or colors.transparent,
						border_color = selected and space_color[name] or colors.transparent,
						corner_radius = 6,
					},
				})
			end
		end
	)
end

local space_observer = sbar.add("item", "spaces.observer", {
	drawing = false,
	updates = true,
	update_freq = 3, -- 取りこぼし対策のポーリング（ウィンドウ移動はイベントが来ないことがある）
})

space_observer:subscribe({
	"aerospace_workspace_change",
	"front_app_switched",
	"space_windows_change",
	"system_woke",
	"routine",
	"forced",
}, function(_)
	update_spaces()
end)

space_observer:subscribe("swap_menus_and_spaces", function(_)
	-- menus.lua 側の表示切り替え後に走らせる
	sbar.delay(0.05, update_spaces)
end)

sbar.add("item", { width = 6 })

-- メニュー/ワークスペース切り替えスイッチ
local spaces_indicator = sbar.add("item", "spaces.indicator", {
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
		border_width = 0,
		corner_radius = 6,
		height = 24,
		padding_left = 6,
		padding_right = 6,
	},
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		padding_left = 6,
		padding_right = 9,
		color = colors.accent1,
		string = icons.switch.on,
	},
	label = {
		drawing = "off",
		padding_left = 0,
		padding_right = 0,
	},
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(_)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(_)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = colors.tn_black1,
				border_color = { alpha = 1.0 },
				padding_left = 6,
				padding_right = 6,
			},
			icon = {
				color = colors.accent1,
				padding_left = 6,
				padding_right = 9,
			},
			label = { drawing = "off" },
			padding_left = 6,
			padding_right = 6,
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(_)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0.0 },
			},
			icon = { color = colors.accent1 },
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(_)
	sbar.trigger("swap_menus_and_spaces")
end)

-- 前面アプリのアイコン
local front_app_icon = sbar.add("item", "front_app_icon", {
	display = "active",
	icon = { drawing = false },
	label = {
		font = "sketchybar-app-font-bg:Regular:21.0",
	},
	updates = true,
	padding_right = 0,
	padding_left = -10,
})

front_app_icon:subscribe("front_app_switched", function(env)
	front_app_icon:set({ label = { string = app_alias.icon_for(env.INFO), color = colors.accent1 } })
end)

sbar.add("bracket", {
	spaces_indicator.name,
	front_app_icon.name,
}, {
	background = {
		color = colors.tn_black3,
		border_color = colors.accent1,
		border_width = 2,
	},
})

-- 初期描画
update_spaces()
