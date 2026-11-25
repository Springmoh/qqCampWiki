# Changelog

## v2.0.5 - 2026-11-25

- Added: `references/WiKi/`, the qqCampWebDev Wiki (Sphinx, Read the Docs
  theme): a Chinese user guide for players, station keepers, game masters,
  the event team and the console, with fresh screenshots and the tutorial
  video, plus the README, CLAUDE.md, changelog, guides and reports. Build it
  with `references/WiKi/build.sh`.
- Added: the wiki is published on GitHub Pages from a separate public
  repository (Springmoh/qqCampWiki), cloned at `references/WiKi/public/`:
  `references/WiKi/publish.sh` copies in only the public part (the user
  guide and the changelog, with the Pages workflow) and checks it for
  private paths; `references/WiKi/build.sh --public` previews it. The wiki's
  internal documents and screenshot tools moved into
  `references/WiKi/internalUse/`, which is never published.
- Added: the DB editor's **Change Log** tab. Every change it makes (edit,
  add, delete, password, restore) is recorded with the old and new values in
  `data/qqcamp.db-changelog`, and each has a **Revert** button. A revert
  checks first that nothing has changed the row since and says what it would
  overwrite if something has; a deleted row comes back with the rows it took
  with it; a revert can itself be reverted.
- Added: the DB editor's Change Log also shows the camp's own activity
  beside the editor's changes, newest first: console and game-master
  actions, money, check-ins, notices, quiz answers, the hall queue, danger
  batches and (optionally) sign-ins, with a filter for Everything, Camp
  activity or Editor changes. Camp entries are view-only.
- Changed: the DB editor is live. It refreshes by itself about once a second
  when the camp server (or another editor) writes, keeps unsaved edits, and
  shows a red note when the open row changes underneath them. The Reload
  button is replaced by a Live indicator (F5 still works).
- Added: the DB editor warns before edits that can break the running camp
  (hand-edited balances, Restrict Activity, the danger-sequence and hall-queue
  tables, check-in rows, tokens, deletes and what they cascade to).
- Changed: `shortcut/resetDb.sh` and `./run.sh --reset` also delete the DB
  editor's change log.

## v2.0.4 - 2026-11-07

- Added: `shortcut/fullInit.sh`, which empties `log/`, wipes the database
  (`resetDb.sh`) and creates the players, checkpoints and game masters from
  the CSVs (`csvInitialize.sh`) in one go. It asks first (`--yes` skips) and
  refuses while the server is running.
- Changed: the stress test moved to `tools/stress/stressTest.sh` (the Gradle
  `stressTest` task follows it) and now simulates the estimated real traffic
  plus 10% (`--headroom`): the pages' real timers and files, plus transfers,
  station check-ins and check-outs, re-sign-ins, station laptops, game
  masters and the event-team screen. Its answer is the recommended number of
  campers online at once.

## v2.0.3 - 2026-11-05

- Added: **显示 QR** on each of a game master's own stations (Overview tab):
  the station's check-in QR, full size on their phone, for a team to scan.
  Only their own stations; every showing is in the audit log (Managers tab
  log: "Showed QR"). `gameMasterQR` in `checkpoint.json` (default true, read
  live) switches it off.
- Changed: the game master's 选择小组 is now a pop-out team list with
  emojis instead of a dropdown.
- Changed: the tutorial's move to Game Stations no longer pauses. While the
  welcome card is open, the tour's steps, the Game Stations page's scripts
  and data and every floor-map picture are loaded into the browser cache,
  and the next page carries on as soon as its words arrive, with no fixed
  wait and no second fetch of the steps.
- Changed: the tutorial after 出发吧 now also walks to the Game Stations
  page and introduces the floor buttons, the map buttons, "You are here",
  the NFC button and the bell (steps whose element is missing, such as
  floors on a one-floor map or NFC switched off, are left out). Each step in
  `usersInfo.json` can name its `page` and be marked `optional`.
- Changed: the NFC pop-out closes with an × in its top right corner instead
  of a 取消 button.
- Changed: the player tab bar (QQ-TNG, Game Stations) is left-aligned, with
  the NFC button and the notification bell at its right on both pages.
- Added: an **NFC** button on the player pages' tab bar. A station's
  NFC tag holds the same link as its QR. On Android (Chrome, over the https
  link) the button opens a pop-out that reads the tag and checks in, or out
  if already there; on an iPhone, which does not let web pages read NFC, it
  explains that holding the phone to the tag opens the link in Safari by
  itself; other browsers are told to use Android Chrome or the QR.
  `nfcCheckin` in `checkpoint.json` (default true, read live) switches it
  off; its picture is `images.nfcIcon` in `assetsPath.json`.
- Added: **Ask Everyone to Clear Cache** on the console's Dashboard, for when
  the code changed during the game. Every open page -- players, game masters,
  station laptops, the event team desk and the console itself -- shows a
  pop-out with only a **Yes** button (no Cancel, no way to click it away);
  Yes clears that device's cache and reloads. A device that answers is not
  asked again, a device opened for the first time is not asked at all (its
  cache is new), and the same button becomes **Withdraw Cache Request** to
  take it back. Every use is in the audit log.
- Added: `clearCache.remote` in `systemHealth.json` (default true, read
  live) turns the button and the request off. The pop-out's words are
  `clearcache.request.*` in every bundle and the button's are `dashboard.cache.*`.

- Added: `tools/dbEditor/`, a desktop DB editor for fixing the camp database
  by hand after an accident. One tab per area, a switch for every yes/no, QQ
  for money, names instead of ids, search, a backup before the first change,
  an audit row for every change, and a refusal when the row changed since it
  was loaded. `tools/dbEditor/buildAppImage.sh` packs it into
  `QQCampDBEditor-x86_64.AppImage`. It is the Python build's editor brought
  over, re-coloured to the console's theme, with tests that read this build's
  own schema file.
- Added: the DB editor opens `data/qqcamp.db` of this project by default, keeps
  its backups in `data/backups/`, and has **Restore…**: pick a backup from the
  list (or browse to one), see what it holds, and put it back. The current
  database is kept first as a `before-restore` copy, so a restore can be undone.

- Changed: the "You are here" block on the player's Game Stations page is
  simpler. The 总分 heading is gone; the score is one small chip beside the
  "checked in" time, a green dot shows when they are checked in, a long
  station name wraps over two lines instead of being cut off, and the block
  shrinks to just the name when there is nothing else to say.
- Added: `marksHide` in `checkpoint.json` (default false, read live) keeps the
  score off that block entirely; the server then does not send the number to
  the player's page. Scores still count and still show on the console and the
  game master pages.

- Added: a bell icon (at the right of the player tab bar) opens the
  team's notification history, newest first. A reminder or the Welcome On
  Board card can be opened again (read-only); a danger or hall notice is
  listed with when and how it ended, but cannot be opened. A red dot on the
  bell means something new arrived since it was last opened. How many are
  listed is `history.limit` in `usersInfo.json` (default 30).
- Added: the welcome card has a second button, **跳过教程**. **出发吧** now
  starts a short tour of the wallet page: the page dims except one part, a
  card beside it explains it, with "2 / 5", Skip and Next. The steps (which
  part, which words) are `tutorial` in `usersInfo.json`; the words are
  `tutorial.*` in `LocalizationPlayer.properties`. Opening the welcome card
  from the bell runs the tour again.

- Changed: the Players, Checkpoints and Game Masters lists are tables: one
  row each, one column per setting, sortable by clicking a heading. Balance,
  marks, the wallet lock and the restriction (players), seats, the quiz and
  the station page (checkpoints) and the stations a game master runs are
  edited right in their cell and save on their own; the arrow at the end of
  a row opens the rest (emoji, password, lockout, links, who is inside, map,
  delete). On a phone each row folds into a small card.
- Added: a search box above each of those lists (name, emoji, station,
  status, note or who is inside, depending on the list).
- Added: `console.tableColumns` in `systemHealth.json` chooses which columns
  each table shows and in what order (read live; leave it out for all).
- Changed: rarely used actions moved into a "⋯" menu beside the + (Reset All
  Lockouts on Players; Export and the QR download on Checkpoints).
- Added: each Log pop-out has its own search box, and the Log button shows a
  red dot when something new arrived since it was last opened on that device.
- Changed: the console's tabs are simpler. The log on the Players,
  Checkpoints and Notifications tabs no longer sits under the page: a **Log**
  button in the title row opens it in a pop-out (a panel on the right on a
  computer, a sheet from the bottom on a phone).
- Added: the Game Managers tab has a log too (its **Log** button): game
  masters signing in, their prizes, check-ins and releases, and every change
  to their accounts.
- Changed: a game master is created like a player or a checkpoint, from the
  small **+** beside the Game Masters heading, in a pop-out form. Console
  accounts now carry their own heading.
- Added: a **Welcome On Board** card, sent from the Notifications tab's send
  form (Type: Welcome On Board; tick Select all for everyone). With the
  message left blank it sends the words in `usersInfo.json`, which the
  message box shows as its placeholder. Each player
  sees it full screen the first time they open their wallet, even if they
  sign in long after it was sent, and one button closes it for good. Sending
  again replaces a card nobody has opened yet instead of stacking a second.
- Added: the card's title and message are `welcome` in
  `devConfig/usersInfo.json`, its pictures are `images.welcomeOnBoard` and
  `images.qqIcon` in `devConfig/assetsPath.json` (both read live), its other
  words are `notify.welcome.*` (player) and `welcome.*` (console) in the
  bundles, and its accent colour is the new `welcome-accent` theme token.
- Changed: `devConfig/emoji.json` is renamed `usersInfo.json`, and
  `devConfig/floormap.json` is renamed `assetsPath.json` with the floor-map
  settings under `floormap`. The server renames old files once at start-up
  (never over a file that already has the new name), and an old floor-map
  layout still loads.

## v2.0.2 - 2026-11-04

- Added: a game master can now check a camper in at one of their own stations
  by hand, not only release one. Each station card on their Overview has a
  **Check In** picker (campers who are not at any station) and a button. It is
  the console's Force Occupy limited to the stations they run: the seats still
  count, a camper at another station is refused, and the move is audited and
  logged under the game master's name.
- Added: `gameMasterOccupy` in `checkpoint.json` (default true) turns that off
  for the whole camp; the picker disappears and the server refuses the call. It
  is read live, so it can be changed mid-event.
- Added: the picker's words and the "switched off" refusal are in
  `LocalizationGameMaster.properties` (`gm.occupy.*`, `error.gm.occupy.off`).
- Changed: the page a team sees while it is in the hall is simplified, in a
  flat dark green (no gradients): only the title and a countdown ring with the
  time left. The ring is one solid colour and turns yellow when time is running
  low. The hall time is still only information: the desk's Visit Done unlocks
  the phone.
- Added: `queue.hallWarnSeconds` (default 120; 0 = never) in `sequenceTask.json`,
  how many seconds before the end the ring and digits turn yellow. It was a fixed
  120 before.
- Changed: the hall colours moved from indigo to dark green. They are the
  `hall-*` lines in `properties/theme.properties`, plus a new `hall-text`.

## v2.0.1 - 2026-10-26

- Changed: the session, wallet and checkpoints replies are built much faster
  when the camp is large. The emoji list in each of them was built by checking
  every earlier name for every new one, so one request grew with the square of
  the number of campers (17.7 ms for 4,302 campers, 1.1 ms now; the wallet
  went from 20 ms to 3.5 ms). The replies are byte for byte the same. In the
  stress test the camp now handles 5,000 users with no errors (p95 7 ms),
  where it stopped at 3,181.
- Changed: the stress test (`./stressTest.sh`) runs every stage on its own new
  server and a new database holding exactly that stage's campers, and measures
  the best passing stage once more before reporting it (`--confirm`). Before,
  a stage after a larger one ran on the larger stage's leftover campers and a
  server that had already been overloaded, so a `--max-users 5000` run could
  report 2,868 users when `--max-users 3000` passed all 3,000.

## v2.0.0 - 2026-10-26

- Added: the whole server rewritten as a Java + C++ build. Java owns the five
  ports (player 8000, admin 8443, checkpoint 8800, game master 8600, event
  team 8900); a C++20 core reached through JNI holds every rule (wallets,
  sessions, the danger sequence, the hall queue, the station quiz, QR codes,
  the API routes). No Python is needed to run it.
- Added: it serves the same pages and API as the Python v1.x build and reads
  the same `devConfig/*.json` and `properties/*.properties` files. Its
  database format is identical, so it can open the Python camp's data (never
  both servers on one database at once).
- Added: a Gradle build (`./gradlew assemble` builds into `build/app/`,
  `./gradlew check` runs the C++ unit tests and the Web Push self-test, and
  `./gradlew _internalQuickBuild` deletes every build output and rebuilds
  from scratch), plus `run.sh`, `stressTest.sh`, `shortcut/csvInitialize.sh`
  and `shortcut/resetDb.sh`.
- Added: `tools/parity/ParityCheck.sh` (`./gradlew parityCheck`), which plays
  the same 138 scripted requests against both builds and compares every
  answer and page byte for byte; every answer matches.
- Changed: at start-up, `gradle.properties` and `local.properties` in the
  project root are left in place instead of being moved into `properties/`
  with other loose `.properties` files.
- Changed: on the wallet page, To (选择小组) opens a pop-out list of teams,
  each with its emoji, instead of a drop-down; game masters are listed under
  their own heading. Tap a team to choose it; tap outside or Cancel to close.
- Changed: a bare `checkpointIp` (no port) now gets the station port added,
  e.g. `192.168.0.50` becomes `http://192.168.0.50:8800`.
- Changed: a malformed id in a request body (`"playerId": "abc"`) is answered
  "No such player" (404) instead of a 500.
- Changed: Web Push needs no extra package; the JDK does the encryption.
- Changed: requests are read in full by Java before the core sees them, so
  the keep-alive body-draining workaround is no longer needed.
