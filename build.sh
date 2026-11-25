#!/usr/bin/env bash
# Build the qqCampWebDev Wiki into references/WiKi/build/html/.
#
#   references/WiKi/build.sh            # build (only what changed)
#   references/WiKi/build.sh --clean    # throw the old build away first
#   references/WiKi/build.sh --serve    # build, then serve it on http://localhost:8008
#   references/WiKi/build.sh --public   # only what GitHub Pages publishes (user guide + changelog),
#                                       # into build/public/ (.github/workflows/wiki.yml does the same)
#
# The first run makes .venv/ and installs requirements.txt into it.
#
# @author Springmoh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
if [[ ! -x "$HERE/.venv/bin/sphinx-build" ]]; then
    python3 -m venv "$HERE/.venv"
    "$HERE/.venv/bin/pip" install -q -r "$HERE/requirements.txt"
fi
SERVE=false
TAGS=()
OUT="$HERE/build/html"
for arg in "$@"; do
    case "$arg" in
        --clean) rm -rf "$HERE/build" "$HERE/source/_generated" ;;
        --serve) SERVE=true ;;
        --public) TAGS=(-t public); OUT="$HERE/build/public" ;;
        *) echo "Usage: $0 [--clean] [--serve] [--public]" >&2; exit 2 ;;
    esac
done
# The public and full builds share source/_generated/ but not their output:
# -E rereads everything so a page excluded from one is not cached into the other.
"$HERE/.venv/bin/sphinx-build" -b html -q -E "${TAGS[@]}" "$HERE/source" "$OUT"
echo "Built: $OUT/index.html"
if [[ "$SERVE" == true ]]; then
    echo "Serving on http://localhost:8008 (Ctrl+C stops)"
    exec "$HERE/.venv/bin/python" -m http.server 8008 --directory "$OUT"
fi
