# qqCampWebDev Wiki

The project's documentation as one website, built with [Sphinx](https://www.sphinx-doc.org/) and the
Read the Docs theme (the look of the ODrive docs): a left sidebar in sections (User Guide, Developer,
Operations, Reports, Changelog), search, and an outline of each page.

Author: Springmoh

## Build

```bash
references/WiKi/build.sh            # build into references/WiKi/build/html/ (only what changed)
references/WiKi/build.sh --clean    # throw the old build away first (after renaming or deleting a page)
references/WiKi/build.sh --serve    # build, then open http://localhost:8008 in a browser
references/WiKi/build.sh --public   # only what GitHub Pages publishes, into references/WiKi/build/public/
```

The first run creates `references/WiKi/.venv/` and installs `requirements.txt` into it (Sphinx,
sphinx-rtd-theme, myst-parser, sphinx-copybutton, sphinx-tabs, mammoth). Nothing is installed system-wide;
deleting `.venv/` removes it all. Without the script:

```bash
references/WiKi/.venv/bin/sphinx-build -b html references/WiKi/source references/WiKi/build/html
```

Open `references/WiKi/build/html/index.html` directly, or use `--serve` (the embedded reports and the
video play more reliably over http than from a file).

## What is in it, and where it comes from

| Section | Source | How |
| --- | --- | --- |
| 使用说明 · User Guide | `source/userGuide/*.md` + `source/userGuide/images/` | written for users (Chinese); screenshots from `tools/shoot.sh` (console account shown as "admin") |
| Developer, Changelog | `README.md`, `CLAUDE.md`, `changeLog.md`, `tools/tutorialVideo/README.md` | included in place (MyST `{include}`), never copied |
| Operations, Gradle guide | `source/files/*.md` (Cloudflare, Samba, Gradle panel) | the wiki's own copies, included |
| Gradle JNI Guide, Reports | `source/files/gradleJniGuide.html`, `references/plan/*.html` | copied into the site at build time and shown in a frame |
| Code Guide | `source/files/codeGuide.docx` | converted to HTML at build time (mammoth); the .docx is downloadable |
| Tutorial video | `references/plan/qqCampTutorial.mp4` | copied at build time, played on the Player page |

So editing any of those files and running `build.sh` again updates the wiki. A new document goes in
`source/files/` (that folder is never turned into pages by itself), with a small page in `source/` that includes
it and a line in a toctree in `source/index.md`. If it must not be public, add it to `PRIVATE_PAGES` in
`source/conf.py`.

## Publishing on GitHub Pages

The camp project is a private repository, and GitHub Pages is only free for public ones, so the wiki is published
from a **separate public repository** that holds only the public wiki: the user guide and the changelog. The
developer, operations and report pages (`PRIVATE_PAGES` in `source/conf.py`) never leave this computer: they
name the Cloudflare tunnel and home folders, describe the camp's weak points, and carry local paths.

`publish.sh` fills that repository's folder with the public part only: the user-guide pages and screenshots, the
home page (without its local-only links and sidebar sections), the changelog page, the theme, `build.sh`,
`requirements.txt`, and `.github/workflows/wiki.yml` (which does nothing inside the camp project: GitHub only
reads `.github/` at a repository's root). It also copies what those pages take from the project (`changeLog.md`,
the version, the app icon, the tutorial video) into `source/files/`, where `conf.py` looks for them when there is
no project around it. Then it checks the folder for private words and stops if any is found. It never commits.

Once:

1. On github.com create a new **public**, empty repository, e.g. `qqCampWiki` (no README, no licence).
2. Clone it next to the project: `git clone git@github.com:Springmoh/qqCampWiki.git ~/Desktop/File/gameDev_v2.0/qqCampWiki`
3. `references/WiKi/publish.sh ~/Desktop/File/gameDev_v2.0/qqCampWiki`, then in that folder
   `git commit -m "wiki v2.0.5"` and `git push`.
4. In the new repository: **Settings → Pages → Build and deployment → Source: GitHub Actions**. Then
   **Actions → Wiki → Run workflow** (or push again). The site is `https://springmoh.github.io/qqCampWiki/`.

Every update after that is step 3 again: `publish.sh`, commit, push; the workflow rebuilds and publishes it.
Preview exactly what goes online with `build.sh --public --serve`. A new public page has to be added to the
`PUBLIC` list at the top of `publish.sh`.

## Re-taking the screenshots

```bash
references/WiKi/tools/shoot.sh
```

Starts a throwaway server and database on ports 19000-19900 (never the camp's `data/`), lays out demo data
(`tools/setupWiki.py`: four stations, a game master, teams in every danger/hall stage), and drives the real
pages in headless Chrome (`tools/capture.mjs`). It needs `./gradlew assemble` done, Google Chrome, and
`tools/tutorialVideo`'s `npm install` (it borrows that folder's Puppeteer). The player screens of the
tutorial video are copied in as well.

## Files

```
references/WiKi/
├── build.sh  requirements.txt  README.md  publish.sh (fills the public wiki repository)
├── .github/workflows/wiki.yml   the public repository's Pages workflow (copied by publish.sh)
├── source/
│   ├── conf.py              settings (theme, extensions, what is copied/converted)
│   ├── index.md             home page and the sidebar sections
│   ├── userGuide/           the user guide pages and their screenshots
│   ├── files/               the wiki's own documents (included, never pages by themselves)
│   ├── developer/ operations/ reports/    small pages that include or embed the real files
│   ├── _static/custom.css   the camp's colours on the theme
│   └── _templates/footer.html   the author line in every page's footer
├── tools/                   shoot.sh, setupWiki.py, capture.mjs (screenshots)
├── .venv/  build/  source/_generated/     made by the build, git-ignored
```
