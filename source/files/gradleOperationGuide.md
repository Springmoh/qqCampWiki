The panel mixes three kinds of tasks: ones Gradle's Java plugin adds, ones I wrote in `build.gradle`, and Gradle's own help tools. Most of it you will never touch.

## What each group is

**build**: the tasks you use most.

| Task | What it does |
|---|---|
| `assemble` | Builds everything and puts the runnable set in `build/app/`: `QqCampServer.jar`, `libQqCampCore.so` and `QqCampCsvImport`. `run.sh` uses that folder. |
| `_internalQuickBuild` | Deletes all of `build/`, then runs `assemble`. It never touches `data/` or `log/`. Use it when the build seems stale or strange. |
| `build` | `assemble` plus `check`, so it builds everything and then runs all the tests. |
| `clean` | Deletes `build/` only. |
| `jar` | Packs the Java classes into `build/libs/QqCampServer.jar`. |
| `stageApp` | Mine. It copies the jar and the C++ library into `build/app/`. |
| `classes`, `testClasses` | Compile the Java main and test code without packing it. |
| `buildNeeded`, `buildDependents` | For multi-project builds. This project has one module, so you can ignore them. |

**native** (mine): the C++ side.
- `cmakeConfigure` runs CMake once to prepare `build/cmake/`.
- `cmakeBuild` compiles the C++ into `libQqCampCore.so`, `QqCampNativeTests` and `QqCampCsvImport`.

**verification**: the tests.

| Task | What it does |
|---|---|
| `nativeTest` | Runs the C++ unit tests. `-PtestFilter=Wallet` runs only tests whose name contains "Wallet". |
| `webPushSelfTest` | Runs the Java Web Push self-check. |
| `test` | Runs the two above together. |
| `check` | Same as `test`. It does not refresh `build/app/`, so don't rely on it to rebuild what the server loads. |
| `parityCheck` | Compares 138 requests against the Python build. It needs `QQ_PYTHON_BUILD` set. |
| `stressTest` | The load test (`-PstressArgs=--quick` for a short one). |

**application** (collapsed in your screenshot): `runServer` starts the server from the IDE (`-PserverArgs="--seed"` passes flags). Real camps should start from `run.sh`.

**other**: `compileJava`, `compileTestJava`, `processResources` and `processTestResources` are steps inside the build. This project has no resources, so those two do nothing. `prepareKotlinBuildScriptModel` is IntelliJ's own helper.

**build setup**: `wrapper` regenerates `gradlew`. `init` creates a new project, so never run it here. `updateDaemonJvm` pins the JDK Gradle runs on.

**documentation**: `javadoc` makes API docs from the Java comments. Optional.

**help**: Gradle's inspection tools (`tasks`, `projects`, `dependencies`, `properties` and so on). You can skip them. `tasks` is the one worth knowing, because it lists everything.

**Run Configurations**: two shortcuts IntelliJ saved for you, `_internalQuickBuild` and `build`.

## What to do

**After cloning, once:**
1. Install JDK 21+, `build-essential cmake libsqlite3-dev zlib1g-dev`. README §1 has the exact commands.
2. Copy the config templates (README §2). `devConfig/systemHealth.json` is required, because it holds the console login. The other config files are optional.
3. Run `./gradlew _internalQuickBuild`. The first run downloads Gradle itself, so it needs internet.
4. Run `./gradlew check`.
5. Run `./run.sh --seed` for a test server with demo campers.

**After changing Java code** (`src/main/java`): run `./gradlew assemble`, then restart `run.sh`.

**After changing C++ code** (`src/main/cpp`, `src/main/include`):
1. Run `./gradlew nativeTest` for a quick check. It rebuilds only what changed.
2. Run `./gradlew assemble`, then restart `run.sh`. This step matters. `nativeTest` does not update `build/app/`, which is what the server loads. I made that mistake earlier and measured the old library.
3. If the change could alter answers, also run `parityCheck`.

**After changing only `frontend/`, `properties/` or `devConfig/`:** nothing to build. Config and wording are read live. Reload the page.

Run `./gradlew _internalQuickBuild` whenever you move or rename files, change JDK or compiler, or see odd errors.