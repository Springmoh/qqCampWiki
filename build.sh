#!/usr/bin/env bash
# Build the qqCampWebDev Wiki: the full internal wiki into build/html/ and
# the public one (user guide + changelog, what GitHub Pages publishes) into
# build/public/.
#
#   references/WiKi/build.sh            # build both
#   references/WiKi/build.sh --clean    # throw the old builds away first
#   references/WiKi/build.sh --serve    # build both, then serve the full one on http://localhost:8008
#   references/WiKi/build.sh --public   # build only the public one (with --serve: serve that)
#
# In the public wiki repository (made by publish.sh) there is no internalUse/,
# so only the public wiki is built there, whatever the flags.
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
FULL=true
for arg in "$@"; do
    case "$arg" in
        --clean) rm -rf "$HERE/build" "$HERE/source/_generated" ;;
        --serve) SERVE=true ;;
        --public) FULL=false ;;
        *) echo "Usage: $0 [--clean] [--serve] [--public]" >&2; exit 2 ;;
    esac
done
[[ -d "$HERE/internalUse" ]] || FULL=false

# Both builds share source/_generated/ but not their output: -E rereads every
# page, so a page left out of one build is never cached into the other.
build() {
    local out="$1"; shift
    "$HERE/.venv/bin/sphinx-build" -b html -q -E "$@" "$HERE/source" "$out"
    echo "Built: $out/index.html"
}
if [[ "$FULL" == true ]]; then
    build "$HERE/build/html"
fi
build "$HERE/build/public" -t public

if [[ "$SERVE" == true ]]; then
    SITE="$HERE/build/public"
    [[ "$FULL" == true ]] && SITE="$HERE/build/html"
    echo "Serving $SITE on http://localhost:8008 (Ctrl+C stops)"
    exec "$HERE/.venv/bin/python" -m http.server 8008 --directory "$SITE"
fi
