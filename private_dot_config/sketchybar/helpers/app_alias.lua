-- 日本語ロケールでは AeroSpace / sketchybar が返すアプリ名がローカライズされる
-- （例: "ターミナル"）。icon_map.lua は英語名がキーなので、ここで英語名へ寄せる。
local app_icons = require("helpers.icon_map")

local alias = {
	["ターミナル"] = "Terminal",
	["メール"] = "Mail",
	["カレンダー"] = "Calendar",
	["メッセージ"] = "Messages",
	["システム設定"] = "System Settings",
	["プレビュー"] = "Preview",
	["ブック"] = "Books",
	["電卓"] = "Calculator",
	["時計"] = "Clock",
	["ミュージック"] = "Music",
	["メモ"] = "Notes",
	["写真"] = "Photos",
	["リマインダー"] = "Reminders",
	["連絡先"] = "Contacts",
	["マップ"] = "Maps",
	["辞書"] = "Dictionary",
	["天気"] = "Weather",
	["株価"] = "Stocks",
	["フリーボード"] = "Freeform",
	["ホーム"] = "Home",
	["ショートカット"] = "Shortcuts",
	["ポッドキャスト"] = "Podcasts",
	["アクティビティモニタ"] = "Activity Monitor",
	["テキストエディット"] = "TextEdit",
	["QuickTime Player"] = "QuickTime Player",
	["Code"] = "Visual Studio Code",
}

local M = {}

-- アプリ名 → sketchybar-app-font-bg のグリフ
function M.icon_for(app_name)
	local name = alias[app_name] or app_name
	return app_icons[name] or app_icons["default"]
end

return M
