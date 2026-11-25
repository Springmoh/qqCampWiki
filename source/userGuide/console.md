# 管理员 Console

Console 是管理员和技术团队用的电脑页面：看全场、管理小组 / 关卡 / Game Master、发通知、处理意外。
画面上的字是英文，下面用中文说明每个分页能做什么。

## 1. 登录

在**主办电脑**（跑伺服器的那台）的浏览器打开 Console 网址，用管理员帐号登录。
Console 只让指定的电脑打开，其他电脑打开会显示找不到网页。

上面一排是分页：**Dashboard**、**Players**、**Checkpoints**、**Notifications**、**Game Managers**、**Event Team**。
每个标题旁边的 **(i)** 是说明。

## 2. Dashboard：看全场

- 四个数字：小组数、流通中的 QQ、被锁的钱包、Game Master 人数。
- **Floor Map**：每层楼的关卡和里面的小组（左右滑看别的楼层）。
- **Players** 流程图：每个小组现在在 Danger 流程的哪一格。
- 右上角按钮：
  - **Admin Activity**：管理员做过的每一件事。
  - **Recent Sign-ins**：最近的登录（谁、从哪里、成功或失败）。
  - **Ask Everyone to Clear Cache**：营会中途更新了网站时用。所有打开着的画面会跳出「需要清除缓存」，按 **好** 就重新载入。
    已经按过的不会再被问；同一个按钮会变成 **Withdraw Cache Request**，按它收回。

```{figure} images/c-dashboard.png
:class: laptop

Dashboard
```

## 3. Players：小组

一组一行的表格，点表头可以排序，上面的搜寻框可以找名字、表情或关卡。

- **直接在格子里改**：余额、分数、钱包锁（Lock Wallet，锁了不能转出但还能收钱）、限制（Restrict Activity）。改完自动保存。
- **每行最后的箭头**：打开其余设定，例如换表情、改密码、解除登录锁定、删除小组。
- **+**（标题旁）：新增一个小组。**⋯**：不常用的动作，例如 **Reset All Lockouts**（清掉所有人的登录失败记录）。
- 勾选多个小组可以一次改（只改你填了的设定）。
- **Log**：钱的流动记录（谁转给谁、多少）。按钮上有红点代表有新的记录。

:::{container} shots
```{figure} images/c-players.png
:class: laptop

Players 表格
```
```{figure} images/c-log.png
:class: laptop

Log：在右边打开，可以搜寻
```
:::

## 4. Checkpoints：关卡

- 表格里直接改：位子数（改小不会把里面的人赶出去）、答题开关、Station 页面开关。
- **每行箭头**：打卡链接、Station 页面链接（给关卡笔电用）、**New QR**（打卡链接外流时换一个新的）、
  谁在里面（可以 Release，或帮人 Check In）、在地图上的位置、删除。
- **+**：新增关卡。**⋯**：**Export**（每组每题答了几次的试算表）、下载所有关卡的打卡 QR（PNG 和 SVG，可打印）。

:::{warning}
打卡 QR 和链接拿到的人在哪里都能打卡，不要传到群组。外流了就按 **New QR**，旧的马上失效（要重新打印）。
:::

```{figure} images/c-checkpoints.png
:class: laptop

Checkpoints
```

## 5. Notifications：发通知

1. **To**：勾选小组，或 **Select all** 全选。
2. **Type**：
   - **Reminder — message with an OK button**：一般提醒，小组按 OK 关掉。
   - **Danger — countdown, then restriction**：带倒计时的「需要处理」，时间到没处理就会被限制。
   - **Welcome On Board — the welcome card**：全屏的 Welcome On Board 欢迎卡。全选发给所有小组；讯息留空会用预设的欢迎词。
     小组第一次打开钱包就会看到（就算很久之后才登录），再发一次会取代还没被打开的那张。
3. **Message**：要让小组看到的字。
4. 按 **Send Notification**。

上面的数字是：进行中的倒计时、还没回复的、已回复的、倒计时长度。**Log** 里可以看到每一则通知的结果；还在进行中的可以按 **Cancel** 撤回。

```{figure} images/c-notifications.png
:class: laptop

Notifications
```

## 6. Game Managers：Game Master 帐号

- **+**（Game Masters 标题旁）：新增 Game Master，填帐号、密码，勾选他负责的关卡。
- 表格里直接改他负责哪些关卡；箭头打开改密码、删除。
- **Log**：Game Master 的登录、发的奖励、帮人 Check In、Release、显示 QR，以及帐号的每一次变动。
- 下面另有 Console 帐号（管理员）的部分。

```{figure} images/c-managers.png
:class: laptop

Game Managers
```

## 7. Event Team

和节目组的 Event Team 页面一样（见[节目组说明](eventteam.md)），另外多了：

- **重置序列**：彩排用。所有小组回到「不在流程中」（倒计时取消、限制解除、离开礼堂排队），名单保留。
- 勾选小组后按 **Edit stage**：一次把好几个小组移到某个阶段，或改他们的开关。

```{figure} images/c-eventteam.png
:class: laptop

Console 的 Event Team 分页
```

## 8. 意外处理：DB Editor 备份与还原

营会资料（所有帐号、钱包、记录）都在一个资料库档案里。主办电脑上有一个桌面程式 **QQ Camp DB Editor**，
用来备份、还原，或在意外时手动修正资料。

- **备份**：在 DB Editor 里备份，会在 `data/backups/` 产生一个 `.db` 档。伺服器开着也可以备份，结果是完整的一份。
- **还原**：按 **Restore…**，选一个备份，确认内容后还原。还原前会先把现在的资料存成一份 `before-restore` 备份，所以还原也能复原。
- 还原会让备份之后做的所有事（转钱、打卡、登录）消失，登录过的小组要重新登录。能的话先停伺服器再还原。

### 改错了？用 Change Log 复原

DB Editor 做的每一个改动（改资料、新增、删除、改密码、还原）都会记在 **Change Log** 分页，最新的在最上面，
每一笔旁边有 **Revert** 按钮。营会自己发生的事（转钱、Check In / Out、通知、Console 和 Game Master 的操作、
答题、礼堂排队、Danger 批次）也会一起列出来，方便对照是什么时候、谁改了什么；上面可以选 **Everything**、
**Camp activity**（只看营会）或 **Editor changes**（只看 DB Editor）。营会的记录只能看，要复原请用 Console。

- 按 **Revert** 会先说明它要做什么。如果那一行在你改完之后又被营会改过（例如小组又转了钱），
  它会列出会被盖掉的新资料，再问你一次；看清楚再按。
- 删除的资料复原时，跟着一起被删的资料（例如小组的钱包）也会一起回来。
- Revert 本身也会记下来，所以复原错了也可以再复原。

DB Editor 是**即时**的：营会伺服器改了资料，画面一秒左右就会更新，不用按重新整理（右上角显示 **● Live**）。
你正在改的那一行如果被营会改动，会出现红色提示，告诉你哪个栏位变了。
可能弄坏营会的操作（例如直接改余额、改 Restrict、动排队和 Danger 的资料、删除小组）在执行前都会先跳出警告。

:::{tip}
营会开始前：把小组、关卡、Game Master 和地图位置都设定好，用 DB Editor 做一次备份。
彩排之后用 **Restore…** 还原到那一份，营会就从干净的状态开始。
:::
