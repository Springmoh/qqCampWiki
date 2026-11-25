"""Sphinx settings for the qqCampWebDev Wiki.

The look is the Read the Docs theme (the one docs.odriverobotics.com uses):
a left sidebar grouped into sections, an "on this page" outline inside it,
copy buttons on code blocks and tabbed blocks (sphinx-tabs).

The project's README, CLAUDE.md and changeLog.md are included where they
live (MyST {include}), so the wiki never holds a stale copy of them. The
wiki's internal documents (the Cloudflare and Samba guides, the Gradle
guides, the code guide .docx) are in ../internalUse/files/, which is never
published. The .html pages, the reports in references/plan/, the
tutorial video and the .docx are copied into the built site by
collect_sources() below, and the .docx is turned into HTML with mammoth.

Two builds:
  * the full wiki, for this computer (build.sh);
  * the public one, `sphinx-build -t public` (build.sh --public, and the
    GitHub Pages workflow in the public repository): only PUBLIC_PAGES, the
    home page, the player guide and the changelog. Every other page stays
    off the internet: the operations guides name the Cloudflare tunnel and
    home folders, the reports describe the camp's weak points, the developer
    pages carry local paths, and the staff guides describe the surprise
    activities (countdown, hall queue) the campers must not read about.

@author Springmoh
"""
import re
import shutil
from pathlib import Path

HERE = Path(__file__).resolve().parent              # references/WiKi/source
INTERNAL = HERE.parent / "internalUse" / "files"    # internal documents, never published
FILES = HERE / "files"                              # standalone only: what publish.sh copied in
GENERATED = HERE / "_generated"                     # rebuilt on every build, git-ignored
# Inside the camp project the wiki reads the project's own files. In the
# standalone public wiki repository (made by publish.sh) there is no project
# around it, and publish.sh has copied what the public pages need into
# source/files/: changeLog.md, VERSION, app-icon.png, qqCampTutorial.mp4.
ROOT = HERE.parents[2]
STANDALONE = not (ROOT / "build.gradle").is_file()
PLAN = FILES if STANDALONE else ROOT / "references" / "plan"     # where the tutorial video is
ICON = FILES / "app-icon.png" if STANDALONE else ROOT / "frontend" / "img" / "app-icon.png"

# The only pages in the public build; every other page is left out of it. A
# new public page goes here and in publish.sh's PUBLIC list.
PUBLIC_PAGES = ["index.md", "userGuide/player.md", "developer/changelog.md"]
PRIVATE_PAGES = sorted(str(page.relative_to(HERE)) for page in HERE.rglob("*.md")
                       if str(page.relative_to(HERE)) not in PUBLIC_PAGES
                       and not page.relative_to(HERE).parts[0].startswith(("_", "files")))
PUBLIC = tags.has("public")  # noqa: F821 -- Sphinx puts `tags` into this file's namespace


def project_version():
    """The version in build.gradle (version = 'x.y.z'), or files/VERSION when
    standalone, or 'dev'. @author Springmoh"""
    if STANDALONE:
        stamp = FILES / "VERSION"
        return stamp.read_text(encoding="utf-8").strip() if stamp.is_file() else "dev"
    match = re.search(r"^version\s*=\s*'([^']+)'", (ROOT / "build.gradle").read_text(encoding="utf-8"), re.M)
    return match.group(1) if match else "dev"


def collect_sources(public):
    """Copy what the pages link to into _generated/extra/raw/ (served at
    /raw/... by html_extra_path) and convert the .docx. The public build
    copies only the tutorial video. Done at every build, so the wiki always
    shows the current files. @author Springmoh
    """
    extra = GENERATED / "extra" / "raw"
    if extra.exists():
        shutil.rmtree(extra)
    (extra / "plan").mkdir(parents=True)
    for source in sorted(PLAN.iterdir()) if PLAN.is_dir() else []:
        if source.suffix == ".mp4" or (source.suffix == ".html" and not public):
            shutil.copy2(source, extra / "plan" / source.name)
    if public:
        return
    for source in INTERNAL.glob("*.html"):
        shutil.copy2(source, extra / source.name)
    for source in INTERNAL.glob("*.docx"):
        shutil.copy2(source, extra / source.name)
        try:
            import mammoth
            with open(source, "rb") as handle:
                html = mammoth.convert_to_html(handle).value
        except Exception as exc:            # a broken .docx must not stop the wiki building
            html = f"<p><em>{source.name} could not be converted: {exc}</em></p>"
        (GENERATED / f"{source.stem}.html").write_text(html, encoding="utf-8")


collect_sources(PUBLIC)

# -- Project ---------------------------------------------------------------
project = "qqCampWebDev Wiki"
author = "Springmoh"
copyright = "2026, Springmoh"
release = project_version()
version = release
language = "zh_CN"

# -- Extensions ------------------------------------------------------------
extensions = [
    "myst_parser",
    "sphinx_copybutton",
    "sphinx_tabs.tabs",
]
myst_enable_extensions = ["colon_fence", "deflist", "attrs_inline", "attrs_block", "html_image", "substitution"]
myst_substitutions = {"release": release}
myst_heading_anchors = 3            # the README's own #1-requirements style links keep working
suppress_warnings = ["myst.xref_missing", "myst.header", "myst.include"]
source_suffix = {".md": "markdown"}
exclude_patterns = ["_generated/extra", "files", "Thumbs.db", ".DS_Store"]
if PUBLIC:
    exclude_patterns += PRIVATE_PAGES
    suppress_warnings.append("toc.excluded")
templates_path = ["_templates"]

# -- HTML ------------------------------------------------------------------
html_theme = "sphinx_rtd_theme"
html_title = f"qqCampWebDev Wiki v{release}"
html_logo = str(ICON)
html_favicon = str(ICON)
html_static_path = ["_static"]
html_css_files = ["custom.css"]
html_extra_path = [str(GENERATED / "extra")]
html_show_sourcelink = False
html_copy_source = False           # no _sources/*.md copies in the site
html_last_updated_fmt = "%Y-%m-%d"
html_theme_options = {
    "collapse_navigation": False,
    "navigation_depth": 3,
    "titles_only": False,
    "style_nav_header_background": "#14213d",
    "prev_next_buttons_location": "both",
}
html_context = {"author": author}
