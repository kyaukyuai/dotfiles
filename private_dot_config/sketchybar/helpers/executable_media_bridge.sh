#!/usr/bin/env bash
# media-control (ungive/mediaremote-adapter) の stream を sketchybar のカスタムイベントに変換する。
# macOS 15.4 以降、sketchybar 組み込みの media_change イベントと nowplaying-cli は
# MediaRemote の制限で動かないため、/usr/bin/perl 経由でアクセスする media-control を使う。
#
# 発火するイベント: mc_media_change
#   TITLE / ARTIST / ALBUM / APP (bundle id) / STATE (playing|paused|stopped) / ARTWORK (画像パス or 空)
set -u

EVENT="mc_media_change"
ART_DIR="${TMPDIR:-/tmp}/sketchybar-media-$(id -u)"
mkdir -p "$ART_DIR"

command -v media-control >/dev/null 2>&1 || {
  echo "media_bridge: media-control が見つかりません (brew install ungive/media-control/media-control)" >&2
  exit 1
}

# 同名の古いブリッジを止める（自分自身は除く）
for pid in $(pgrep -f "media-control stream"); do
  [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null
done

media-control stream --no-diff --debounce=300 | while IFS= read -r line; do
  # JSON → シェル変数（python3 は macOS 同梱の Command Line Tools 版で十分）
  eval "$(printf '%s' "$line" | ART_DIR="$ART_DIR" python3 -c '
import sys, json, os, base64, hashlib, shlex, glob

try:
    msg = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)

payload = msg.get("payload") if isinstance(msg, dict) else None
if payload is None:
    payload = msg if isinstance(msg, dict) else {}

def s(v):
    return "" if v is None else str(v)

title  = s(payload.get("title"))
artist = s(payload.get("artist"))
album  = s(payload.get("album"))
app    = s(payload.get("bundleIdentifier"))
playing = payload.get("playing")
if not title:
    state = "stopped"
elif playing:
    state = "playing"
else:
    state = "paused"

art_path = ""
data = payload.get("artworkData")
if data and title:
    mime = s(payload.get("artworkMimeType")) or "image/jpeg"
    ext = {"image/png": "png", "image/jpeg": "jpg", "image/jpg": "jpg", "image/gif": "gif", "image/tiff": "tiff"}.get(mime, "jpg")
    key = hashlib.md5((title + "|" + artist + "|" + album).encode()).hexdigest()[:12]
    art_dir = os.environ["ART_DIR"]
    art_path = os.path.join(art_dir, "art-" + key + "." + ext)
    if not os.path.exists(art_path):
        try:
            with open(art_path, "wb") as f:
                f.write(base64.b64decode(data))
            # 古いアートワークを掃除（直近 8 件だけ残す）
            files = sorted(glob.glob(os.path.join(art_dir, "art-*")), key=os.path.getmtime)
            for old in files[:-8]:
                try: os.remove(old)
                except OSError: pass
        except Exception:
            art_path = ""

for k, v in [("TITLE", title), ("ARTIST", artist), ("ALBUM", album), ("APP", app), ("STATE", state), ("ARTWORK", art_path)]:
    print("%s=%s" % (k, shlex.quote(v)))
')"
  sketchybar --trigger "$EVENT" \
    TITLE="${TITLE:-}" ARTIST="${ARTIST:-}" ALBUM="${ALBUM:-}" \
    APP="${APP:-}" STATE="${STATE:-stopped}" ARTWORK="${ARTWORK:-}"
done
