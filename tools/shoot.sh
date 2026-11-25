#!/usr/bin/env bash
# Re-take the wiki's user-guide screenshots: a NEW throwaway server and
# database (ports 19000-19900, never the camp's own data/), the demo from
# setupWiki.py, then capture.mjs, then stop the server. The player screens of
# the tutorial video (tools/tutorialVideo/video/assets/shots) are copied too.
# Needs ./gradlew assemble done, tools/tutorialVideo's npm install (for
# Puppeteer) and nothing else on ports 19xxx.
#
#   references/WiKi/tools/shoot.sh
#
# @author Springmoh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../../.." && pwd)"
OUT="$HERE/../source/userGuide/images"
WORK="$(mktemp -d /tmp/qqcamp-wiki-XXXXXX)"
trap 'kill "$SERVER" 2>/dev/null || true; rm -rf "$WORK"' EXIT

# A scratch project root: this build's pages, words and pictures linked in,
# and a copy of devConfig/ whose console account is a neutral "admin" with a
# throwaway password, so no real account name ends up in a screenshot.
mkdir -p "$WORK/root/devConfig"
for name in frontend properties assets shortcut; do ln -s "$ROOT/$name" "$WORK/root/$name"; done
cp "$ROOT"/devConfig/*.json "$WORK/root/devConfig/"
[[ -d "$ROOT/devConfig/floormaps" ]] && ln -s "$ROOT/devConfig/floormaps" "$WORK/root/devConfig/floormaps"
HEALTH="$WORK/root/devConfig/systemHealth.json"
python3 - "$HEALTH" <<'PY'
import json, secrets, sys
path = sys.argv[1]
config = json.load(open(path, encoding="utf-8"))
config.setdefault("admin", {}).update({"admin_user": "admin", "admin_password": secrets.token_urlsafe(12)})
json.dump(config, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
PY

cd "$ROOT"
QQ_ROOT="$WORK/root" QQ_DB_PATH="$WORK/q.db" QQ_LOG_DIR="$WORK" java --enable-native-access=ALL-UNNAMED \
    -Dqqcamp.home="$ROOT" -jar build/app/QqCampServer.jar --host 127.0.0.1 --port 19000 \
    --admin-port 19443 --checkpoint-port 19800 --gamemaster-port 19600 --eventteam-port 19900 \
    --seed > "$WORK/server.out" 2>&1 &
SERVER=$!
for _ in $(seq 40); do curl -s -o /dev/null http://127.0.0.1:19000/ && break; sleep 0.5; done

python3 "$HERE/setupWiki.py" "$HEALTH"
PAGE=$(sqlite3 "$WORK/q.db" "select page_token from checkpoints where id = 2")
mkdir -p "$OUT"
cp "$ROOT"/tools/tutorialVideo/video/assets/shots/*.png "$OUT"/
node "$HERE/capture.mjs" "$ROOT" "$PAGE" "$OUT" "$HEALTH"
