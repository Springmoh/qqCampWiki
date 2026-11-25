#!/usr/bin/env bash
# Copy the PUBLIC part of the wiki into the public wiki repository's folder,
# ready to commit and push. GitHub Pages then builds and publishes it
# (.github/workflows/wiki.yml, copied along).
#
#   references/WiKi/publish.sh <folder of the public wiki repository>
#
# What goes over: the user guide (pages + screenshots), the home page, the
# developer changelog page, the theme, the build files and the workflow, plus
# copies of what those pages take from the camp project (changeLog.md, the
# version, the app icon, the tutorial video) into source/files/.
#
# What never goes over: the developer, operations and report pages and their
# documents (PRIVATE_PAGES in source/conf.py: the Cloudflare tunnel, home
# folders, the camp's weak points), tools/, and anything git-ignored. The
# folder is checked for private words afterwards; it stops if any is found.
#
# It only copies. Committing and pushing is yours (the commands are printed).
#
# @author Springmoh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <folder of the public wiki repository (a git clone)>" >&2
    exit 2
fi
DEST="$(cd "$1" 2>/dev/null && pwd)" || { echo "No such folder: $1" >&2; exit 2; }
if ! git -C "$DEST" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "$DEST is not a git repository: clone the new wiki repository first." >&2
    exit 2
fi
if [[ "$(git -C "$DEST" rev-parse --show-toplevel)" == "$(git -C "$ROOT" rev-parse --show-toplevel)" ]]; then
    echo "$DEST is inside the camp project itself; give the public wiki repository's folder." >&2
    exit 2
fi

# The public file list. A new public page goes here too.
PUBLIC=(
    .github/workflows/wiki.yml
    requirements.txt
    build.sh
    source/conf.py
    source/index.md
    source/_static
    source/_templates
    source/userGuide
    source/developer/changelog.md
)

# Start from an empty tree (keeping .git), so a file removed here is removed there.
find "$DEST" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
for path in "${PUBLIC[@]}"; do
    mkdir -p "$DEST/$(dirname "$path")"
    cp -R "$HERE/$path" "$DEST/$path"
done

# What the public pages take from the camp project.
mkdir -p "$DEST/source/files"
cp "$ROOT/changeLog.md" "$DEST/source/files/changeLog.md"
cp "$ROOT/frontend/img/app-icon.png" "$DEST/source/files/app-icon.png"
cp "$ROOT/references/plan/qqCampTutorial.mp4" "$DEST/source/files/qqCampTutorial.mp4"
sed -n "s/^version *= *'\([^']*\)'.*/\1/p" "$ROOT/build.gradle" > "$DEST/source/files/VERSION"
sed -i 's#../../../../changeLog.md#../files/changeLog.md#' "$DEST/source/developer/changelog.md"
# The home page's local-only block (links to the private pages) and the
# Developer / Operations / Reports sidebar sections are not even shipped as text.
python3 - "$DEST/source/index.md" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
text = re.sub(r"````\{only\} not public\n.*?\n````\n\n?", "", text, flags=re.S)
# ... and the sidebar sections that only list private pages.
text = re.sub(r"```\{toctree\}\n:caption: (Developer|Operations|Reports)\n.*?\n```\n\n?", "", text, flags=re.S)
open(path, "w", encoding="utf-8").write(text)
PY

cat > "$DEST/.gitignore" <<'EOF'
.venv/
build/
_site/
source/_generated/
__pycache__/
EOF
VERSION="$(cat "$DEST/source/files/VERSION")"
cat > "$DEST/README.md" <<EOF
# qqCampWebDev Wiki

The user guide of SCMC QQ Camp (v$VERSION): how players, station keepers, game masters, the event team
and the console use the camp website, in Chinese, with screenshots and the tutorial video.

Author: Springmoh

Published on GitHub Pages by \`.github/workflows/wiki.yml\` on every push to \`main\`.
Build it locally with \`./build.sh --public --serve\` (it makes a \`.venv/\` with Sphinx on first run).

This repository is generated: edit the wiki in the camp project (\`references/WiKi/\`) and run its
\`publish.sh\` again.
EOF

# Nothing private may have come along.
if grep -rIl -e 'cloudflared' -e '60a9b8f4' -e '/home/' "$DEST" --exclude-dir=.git --exclude=wiki.yml; then
    echo "Stopped: the files above contain private paths or tunnel details. Nothing was committed." >&2
    exit 1
fi

echo "Copied the public wiki (v$VERSION) into $DEST:"
git -C "$DEST" add -A
git -C "$DEST" status --short | head -40
echo
echo "Next:"
echo "  cd \"$DEST\""
echo "  git commit -m \"wiki v$VERSION\""
echo "  git push"
