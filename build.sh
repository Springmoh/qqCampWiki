#!/usr/bin/env bash
# Build the qqCampWebDev Wiki.
#
# In the camp project it first brings public/ (the public wiki repository's
# clone) up to date with publish.sh, cloning it if it is missing, then builds
#   - the full internal wiki from source/   into build/html/
#   - the public wiki from public/           into build/public/
# so build/public/ is exactly what GitHub Pages will build from that
# repository. Nothing is committed or pushed; publish.sh stages the changes in
# public/ and prints the commit and push commands.
#
#   references/WiKi/build.sh            # sync public/, build both
#   references/WiKi/build.sh --clean    # throw the old builds away first
#   references/WiKi/build.sh --serve    # ... then serve the full wiki on http://localhost:8008
#   references/WiKi/build.sh --public   # sync public/, build only the public wiki (with --serve: serve it)
#
# In the public wiki repository itself (no internalUse/, no publish.sh) it
# just builds that repository's wiki into build/public/.
#
# The first run makes .venv/ and installs requirements.txt into it.
#
# @author Springmoh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PUBLIC_REPO="git@github.com:Springmoh/qqCampWiki.git"
if [[ ! -x "$HERE/.venv/bin/sphinx-build" ]]; then
    python3 -m venv "$HERE/.venv"
    "$HERE/.venv/bin/pip" install -q -r "$HERE/requirements.txt"
fi
SERVE=false
FULL=true
for arg in "$@"; do
    case "$arg" in
        --clean) rm -rf "$HERE/build" "$HERE/source/_generated" "$HERE/public/source/_generated" ;;
        --serve) SERVE=true ;;
        --public) FULL=false ;;
        *) echo "Usage: $0 [--clean] [--serve] [--public]" >&2; exit 2 ;;
    esac
done

# -E rereads every page, so nothing of one build is cached into the other.
build() {
    local src="$1" out="$2"; shift 2
    "$HERE/.venv/bin/sphinx-build" -b html -q -E "$@" "$src" "$out"
    echo "Built: $out/index.html"
}

if [[ ! -d "$HERE/internalUse" || ! -x "$HERE/publish.sh" ]]; then
    # The public wiki repository: only its own wiki.
    build "$HERE/source" "$HERE/build/public" -t public
    [[ "$SERVE" == true ]] && exec "$HERE/.venv/bin/python" -m http.server 8008 --directory "$HERE/build/public"
    exit 0
fi

# 1. public/: clone the public repository if it is not there (or start a new
#    one pointing at it when GitHub cannot be reached), then sync it.
if [[ ! -d "$HERE/public/.git" ]]; then
    if [[ -e "$HERE/public" && -n "$(ls -A "$HERE/public" 2>/dev/null)" ]]; then
        echo "Stopped: $HERE/public exists but is not a git clone; move it away and run again." >&2
        exit 2
    fi
    rm -rf "$HERE/public"
    if ! git clone -q "$PUBLIC_REPO" "$HERE/public" 2>/dev/null; then
        echo "Could not clone $PUBLIC_REPO; starting a new repository in public/ pointing at it."
        git init -q -b main "$HERE/public"
        git -C "$HERE/public" remote add origin "$PUBLIC_REPO"
    fi
fi
LOG="$(mktemp)"
"$HERE/publish.sh" "$HERE/public" > "$LOG" 2>&1 || { cat "$LOG" >&2; rm -f "$LOG"; exit 1; }
rm -f "$LOG"
CHANGES=$(git -C "$HERE/public" status --porcelain | wc -l)
echo "Synced public/: $CHANGES change(s) staged there (commit and push them to publish)."

# 2. The builds.
if [[ "$FULL" == true ]]; then
    build "$HERE/source" "$HERE/build/html"
fi
build "$HERE/public/source" "$HERE/build/public" -t public

if [[ "$SERVE" == true ]]; then
    SITE="$HERE/build/public"
    [[ "$FULL" == true ]] && SITE="$HERE/build/html"
    echo "Serving $SITE on http://localhost:8008 (Ctrl+C stops)"
    exec "$HERE/.venv/bin/python" -m http.server 8008 --directory "$SITE"
fi
