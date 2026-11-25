# qqCampWebDev Wiki

**SCMC QQ Camp** 的说明书和开发资料，集中在一个地方。

作者 Author: **Springmoh** · 版本 Version: **v{{ release }}**

## 从哪里开始

| 我想…… | 去这里 |
| --- | --- |
| 学会用网站（营员、关主、Game Master、节目组、管理员） | [使用说明 · User Guide](userGuide/index.md) |
| 知道每个版本改了什么 | [Changelog](developer/changelog.md) |

````{only} not public
| 开发和部署 | 去这里 |
| --- | --- |
| 在电脑上建置、执行这个伺服器 | [README](developer/readme.md) |
| 把网站接到 game.scmcqqcamp.com | [Cloudflare Tunnel Setup](operations/cloudflaredSetupGuide.md) |
| 看风险和压力测试报告 | [Reports](reports/riskAnalysisReportCN.md) |

## 这个 Wiki 怎么来的

所有页面都由 Sphinx 从项目里的档案产生：`README.md`、`CLAUDE.md`、`changeLog.md` 是直接引用原档，
其他文件放在 `references/WiKi/source/files/`，`.html` 原样嵌入，`codeGuide.docx` 每次建置时转成网页。
所以改了原档，重新建置一次 Wiki 就会更新。发布到 GitHub 的公开版只有使用说明和 Changelog。
重新建置和发布的方法见 [关于这个 Wiki](developer/wiki.md)。
````

```{toctree}
:caption: 使用说明 · User Guide
:hidden:
:maxdepth: 2

userGuide/index
userGuide/player
userGuide/station
userGuide/gamemaster
userGuide/eventteam
userGuide/console
```

```{toctree}
:caption: Developer
:hidden:
:maxdepth: 2

developer/readme
developer/claude
developer/gradleOperationGuide
developer/gradleJniGuide
developer/codeGuide
developer/tutorialVideo
developer/wiki
```

```{toctree}
:caption: Operations
:hidden:
:maxdepth: 2

operations/cloudflaredSetupGuide
operations/cloudflareTunnelCheatsheet
operations/sambaSetupGuide
```

```{toctree}
:caption: Reports
:hidden:
:maxdepth: 1

reports/riskAnalysisReport
reports/riskAnalysisReportCN
reports/stressTestReport
```

```{toctree}
:caption: Changelog
:hidden:
:maxdepth: 1

developer/changelog
```
