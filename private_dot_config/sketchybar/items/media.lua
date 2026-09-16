-- 再生中メディア（アートワーク + アーティスト/タイトル + 再生コントロール）
-- macOS 15.4 以降は sketchybar 組み込みの media_change / nowplaying-cli が使えないため、
-- helpers/media_bridge.sh (media-control) が発火する mc_media_change を購読する。
local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- 表示対象のアプリ (bundle id)。nil にすると全アプリを表示。
local whitelist = nil
-- local whitelist = {
-- 	["com.spotify.client"] = true,
-- 	["com.apple.Music"] = true,
-- 	["com.google.Chrome"] = true,
-- }

sbar.add("event", "mc_media_change")
sbar.exec("killall media_bridge.sh >/dev/null 2>&1; $CONFIG_DIR/helpers/media_bridge.sh >/dev/null 2>&1 &")

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	background = {
		image = {
			scale = 0.85,
			corner_radius = 6,
		},
		color = colors.transparent,
		border_width = 0,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = false,
	updates = true,
	popup = {
		align = "center",
		horizontal = true,
		background = {
			color = colors.tn_black3,
			border_color = colors.accent1,
			border_width = 2,
		},
	},
})

local media_artist = sbar.add("item", "media.artist", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = {
			size = 9,
			style = settings.font.style_map["Bold"],
		},
		color = colors.accent3,
		max_chars = 18,
		y_offset = 6,
	},
	background = { drawing = "off" },
})

local media_title = sbar.add("item", "media.title", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = {
			size = 11,
			style = settings.font.style_map["Bold"],
		},
		width = 0,
		max_chars = 16,
		y_offset = -5,
		color = colors.accent1,
	},
})

sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = {
		string = icons.media.back,
		font = { size = 10 },
		color = colors.accent1,
	},
	label = { drawing = false },
	click_script = "media-control previous-track",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = {
		string = icons.media.play_pause,
		font = { size = 10 },
		color = colors.accent1,
	},
	label = { drawing = false },
	click_script = "media-control toggle-play-pause",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = {
		string = icons.media.forward,
		font = { size = 10 },
		color = colors.accent1,
	},
	label = { drawing = false },
	click_script = "media-control next-track",
})

local interrupt = 0
local function animate_detail(detail)
	if not detail then
		interrupt = interrupt - 1
	end
	if interrupt > 0 and not detail then
		return
	end

	sbar.animate("tanh", 30, function()
		media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		media_title:set({ label = { width = detail and "dynamic" or 0 } })
	end)
end

local current_artwork = nil

media_cover:subscribe("mc_media_change", function(env)
	if whitelist and not whitelist[env.APP or ""] then
		return
	end
	local drawing = (env.STATE == "playing" or env.STATE == "paused")
	media_artist:set({ drawing = drawing, label = env.ARTIST or "" })
	media_title:set({ drawing = drawing, label = env.TITLE or "" })

	local artwork = env.ARTWORK or ""
	if drawing and artwork ~= "" then
		if artwork ~= current_artwork then
			current_artwork = artwork
			media_cover:set({ background = { image = { string = artwork, drawing = true } } })
		end
	else
		media_cover:set({ background = { image = { drawing = false } } })
	end
	media_cover:set({ drawing = drawing })

	if drawing then
		animate_detail(true)
		interrupt = interrupt + 1
		sbar.delay(5, animate_detail)
	else
		media_cover:set({ popup = { drawing = false } })
	end
end)

media_cover:subscribe("mouse.entered", function(_)
	interrupt = interrupt + 1
	animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(_)
	animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function(_)
	media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function(_)
	media_cover:set({ popup = { drawing = false } })
end)
