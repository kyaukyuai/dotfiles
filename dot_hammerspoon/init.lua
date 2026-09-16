-- Hammerspoon: 3840x1080 ウルトラワイド向けの 4 列固定レイアウト
--
--   [ Codex ][ Claude ][ 切替 1 枚 ][ Slack ]
--
-- 1・2・4 列目は常に同じアプリ（PINNED）。3 列目は alt+キーで選んだアプリ（SWITCH）に入れ替わる。
-- タイル型 WM で木構造を維持するより、アプリ名で位置を決めてしまう方が確実なのでこの形にした。
-- 切替列のウィンドウは同じ枠に重ねて置く（前面の 1 枚だけ見える）。同じアプリの複数窓は alt+j で巡回。
-- 4 列のフォーカス移動: alt+1〜4 で列を直接指定、alt+h / alt+l で左右へ。
--
-- sketchybar 連携: 切替列の状態を left_column_change イベント (KEY=<key>) で通知し、
-- sketchybar 側 (items/switcher.lua) はクリックで hammerspoon://switch?key=<key> を開いて切り替える。
--
-- 必要な権限: システム設定 > プライバシーとセキュリティ > アクセシビリティ に Hammerspoon を追加。
-- 設定を保存すると自動で再読み込みされる。

hs.autoLaunch(true)
hs.window.animationDuration = 0
require("hs.ipc") -- `hs -c '...'` CLI

-- アクセシビリティ権限が無いとウィンドウ操作ができない。未付与ならシステム設定を促し、
-- 付与された時点で自動的に再起動して整列する（初回セットアップ用）。
-- macOS 26 では付与後にプロセスを起動し直さないと一部アプリ（Claude 等）の AX ツリーが読めないため、
-- hs.reload() ではなく hs.relaunch() を使う。
if not hs.accessibilityState(true) then
	hs.alert.show("Hammerspoon にアクセシビリティ権限を付与してください", 5)
	hs.timer.waitUntil(hs.accessibilityState, function()
		hs.relaunch()
	end, 2)
end

local GAP = 10
local TOP = 54 -- sketchybar (44px) + GAP。メニューバーは自動非表示前提
-- 列幅の比率（左から）。Slack は狭め、他は均等。
-- Slack はウィンドウの最小幅が約 668px なので、それを下回る比率にすると画面右端からはみ出す。
local COL_WEIGHTS = { 1, 1, 1, 0.65 }
local COLS = #COL_WEIGHTS
local SKETCHYBAR = "/opt/homebrew/bin/sketchybar"

-- 固定列のアプリ（bundle id → 列番号）
local PINNED = {
	["com.openai.codex"] = 1, -- ChatGPT / Codex
	["com.anthropic.claudefordesktop"] = 2, -- Claude
	["com.tinyspeck.slackmacgap"] = 4, -- Slack（右端）
}
-- 切替アプリが入る列
local SWITCH_COL = 3

-- alt+key → 切替列に出すアプリ。title を指定するとウィンドウタイトルで絞る（Chrome のプロフィール別）。
-- この並びが sketchybar の表示順。sketchybar 側 (items/switcher.lua) の一覧と揃えること。
local SWITCH = {
	{ key = "t", id = "com.mitchellh.ghostty" }, -- Terminal
	{ key = "e", id = "dev.zed.Zed" }, -- Editor
	{ key = "c", id = "com.todesktop.230313mzl4w4u92" }, -- Cursor
	{ key = "b", id = "com.google.Chrome", title = "Google Chrome - 勇哉" }, -- Browser（仕事プロフィール）
	{ key = "p", id = "com.google.Chrome", title = "Google Chrome - yuya" }, -- Personal（個人プロフィール）
	{ key = "m", id = "com.readdle.SparkDesktop.appstore" }, -- Mail
	{ key = "n", id = "notion.id" }, -- Notion
	{ key = "g", id = "com.anysphere.sand" }, -- Grok Bot
	{ key = "f", id = "com.apple.finder" },
}
local SWITCH_BY_KEY = {}
for _, spec in ipairs(SWITCH) do
	SWITCH_BY_KEY[spec.key] = spec
end

local function colFrame(col)
	local f = hs.screen.primaryScreen():fullFrame()
	local total = 0
	for _, wt in ipairs(COL_WEIGHTS) do
		total = total + wt
	end
	local unit = (f.w - GAP * (COLS + 1)) / total
	local x = f.x + GAP
	for i = 1, col - 1 do
		x = x + COL_WEIGHTS[i] * unit + GAP
	end
	return hs.geometry.rect(x, f.y + TOP, COL_WEIGHTS[col] * unit, f.h - TOP - GAP)
end

local function bundleOf(win)
	local app = win and win:application()
	return app and app:bundleID() or ""
end

local function isPinned(win)
	return PINNED[bundleOf(win)] ~= nil
end

local function colOf(win)
	return PINNED[bundleOf(win)] or SWITCH_COL
end

local function matches(win, spec)
	if bundleOf(win) ~= spec.id then
		return false
	end
	return spec.title == nil or (win:title() or ""):find(spec.title, 1, true) ~= nil
end

-- ウィンドウに対応する切替キー（title 指定のある項目を優先）
local function keyForWindow(win)
	local fallback = nil
	for _, spec in ipairs(SWITCH) do
		if matches(win, spec) then
			if spec.title then
				return spec.key
			end
			fallback = fallback or spec.key
		end
	end
	return fallback
end

-- sketchybar に左列の状態を通知（sketchybar 未導入でも無害）
local function notifyBar(key)
	hs.task.new(SKETCHYBAR, nil, { "--trigger", "left_column_change", "KEY=" .. (key or "") }):start()
end

-- ウィンドウを担当列に置く（標準ウィンドウのみ。ダイアログ等は触らない）
local function place(win)
	if not win or not win:isStandard() then
		return
	end
	win:setFrame(colFrame(colOf(win)), 0)
end

local function layoutAll()
	for _, win in ipairs(hs.window.allWindows()) do
		place(win)
	end
end

-- 切替列のアプリを切り替える
local function switchTo(spec)
	local apps = hs.application.applicationsForBundleID(spec.id)
	local app = apps and apps[1]
	if not app then
		hs.application.launchOrFocusByBundleID(spec.id) -- 起動後は windowCreated で配置される
		notifyBar(spec.key)
		return
	end
	-- 一致する標準ウィンドウを前面順に集める
	local wins = {}
	for _, win in ipairs(hs.window.orderedWindows()) do
		if win:isStandard() and matches(win, spec) then
			table.insert(wins, win)
		end
	end
	if #wins == 0 then
		app:activate() -- 一致する窓が無ければアプリを前面に（非表示解除）
		notifyBar(spec.key)
		return
	end
	-- すでにそのアプリが前面なら同じキーの再押下で次の窓へ（一番後ろの窓を前に出す）
	local focused = hs.window.focusedWindow()
	local target = wins[1]
	if #wins > 1 and focused and focused:id() == wins[1]:id() then
		target = wins[#wins]
	end
	place(target)
	target:focus()
	notifyBar(spec.key)
end

-- 切替列に重なっているウィンドウを巡回（一番後ろのものを前に出す）
local function cycleSwitchColumn()
	local col = {}
	for _, win in ipairs(hs.window.orderedWindows()) do
		if win:isStandard() and not isPinned(win) then
			table.insert(col, win)
		end
	end
	if #col > 1 then
		place(col[#col])
		col[#col]:focus()
	end
end

-- N 列目の前面ウィンドウへフォーカス
local function focusColumn(n)
	for _, win in ipairs(hs.window.orderedWindows()) do
		if win:isStandard() and colOf(win) == n then
			win:focus()
			return
		end
	end
end

-- 左右の列へフォーカス移動
local function focusDir(dir)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	if dir == "west" then
		win:focusWindowWest(nil, true, true)
	else
		win:focusWindowEast(nil, true, true)
	end
end

-- いま切替列の前面にあるウィンドウのキーを通知
local function syncBar()
	for _, win in ipairs(hs.window.orderedWindows()) do
		if win:isStandard() and not isPinned(win) then
			notifyBar(keyForWindow(win))
			return
		end
	end
	notifyBar("")
end

for _, spec in ipairs(SWITCH) do
	hs.hotkey.bind({ "alt" }, spec.key, function()
		switchTo(spec)
	end)
end
hs.hotkey.bind({ "alt" }, "j", cycleSwitchColumn)
for n = 1, COLS do
	hs.hotkey.bind({ "alt" }, tostring(n), function()
		focusColumn(n)
	end)
end
hs.hotkey.bind({ "alt" }, "h", function()
	focusDir("west")
end)
hs.hotkey.bind({ "alt" }, "l", function()
	focusDir("east")
end)
hs.hotkey.bind({ "alt", "shift" }, "r", layoutAll) -- 崩れたら整列し直す

-- sketchybar からの操作: hammerspoon://switch?key=t / hammerspoon://sync
hs.urlevent.bind("switch", function(_, params)
	local spec = params and SWITCH_BY_KEY[params.key or ""]
	if spec then
		switchTo(spec)
	end
end)
hs.urlevent.bind("sync", syncBar)

local wf = hs.window.filter.default
-- 新しいウィンドウは出現時に担当列へ
wf:subscribe({ hs.window.filter.windowCreated, hs.window.filter.windowUnhidden }, function(win)
	place(win)
end)
-- 切替列のウィンドウにフォーカスが移ったら bar のハイライトを更新
wf:subscribe(hs.window.filter.windowFocused, function(win)
	if win and win:isStandard() and not isPinned(win) then
		notifyBar(keyForWindow(win))
	end
end)

-- ウォッチャーはグローバルに保持する（ローカルだと GC に回収されて動かなくなる）
-- ディスプレイ構成が変わったら整列し直す
ScreenWatcher = hs.screen.watcher.new(layoutAll):start()

-- 設定ファイル保存時に自動リロード。
-- hs.pathwatcher は macOS 26 + Hammerspoon 1.1.1 でイベントが届かなかったので、更新時刻のポーリングで代替する。
local CONFIG_PATH = os.getenv("HOME") .. "/.hammerspoon/init.lua"
local function configMtime()
	local attr = hs.fs.attributes(CONFIG_PATH)
	return attr and attr.modification or 0
end
local configLoadedMtime = configMtime()
ConfigWatcher = hs.timer.doEvery(2, function()
	if configMtime() ~= configLoadedMtime then
		hs.reload()
	end
end)

-- スリープ復帰後にウィンドウがずれることがあるので整列し直す
WakeWatcher = hs.caffeinate.watcher.new(function(event)
	if event == hs.caffeinate.watcher.systemDidWake or event == hs.caffeinate.watcher.screensDidWake or event == hs.caffeinate.watcher.screensDidUnlock then
		hs.timer.doAfter(2, layoutAll)
	end
end):start()

-- CLI からの操作・検証用: hs -c 'Layout.focusColumn(3)'
Layout = { layoutAll = layoutAll, switchTo = switchTo, focusColumn = focusColumn, syncBar = syncBar, SWITCH = SWITCH_BY_KEY }

layoutAll()
syncBar()
hs.alert.show("Hammerspoon: 4 列レイアウト", 1)
