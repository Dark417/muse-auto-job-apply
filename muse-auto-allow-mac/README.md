**中文** | [English](#english)

# Muse Auto Allow：Mac 应用

一个在后台运行的小 Mac 应用。Muse 桌面应用请求批准时（比如上传简历），它会自动点 **Allow**。

- 每 **2 分钟**检查一次，把所有待批准的请求都点掉，每次间隔 2 秒。
- 它通过 macOS 的辅助功能读 Muse 的界面，不会动你的鼠标，也不截图。
- ⚠️ 它会批准**所有**请求，不只是上传。只想批准上传，见下面"自定义"。

## 安装（只需一次）

1. 先装 Xcode 命令行工具：在终端运行 `xcode-select --install`。
2. 下载并编译：
   ```
   git clone https://github.com/Dark417/muse-auto-job-apply
   cd muse-auto-job-apply/muse-auto-allow-mac
   ./build.sh
   ```
   这会在当前文件夹里生成 `MuseAutoAllow.app`。
3. 给权限：系统设置 → 隐私与安全性 → **辅助功能** → **+** → 选这个文件夹里的 `MuseAutoAllow.app` → **打开开关**。

## 使用

1. 打开 Muse 桌面应用，打开**右侧面板**，点 **Approvals** 标签（盾牌图标），会看到 "Needs review" 列表。就停在这里。
2. 双击 **`muse-on.command`**。它会在后台运行，弹出的终端窗口可以关掉。如果已经在运行，会弹提示，不会重复启动。
3. 停止：双击 **`muse-off.command`**。

> ⚠️ **Muse 必须一直停在 Approvals 页面。** 关掉面板、切到 Activity / Upcoming / Identity、或者退出 Muse，它就什么都点不到。Muse 窗口被别的窗口挡住没关系。

> ⚠️ Mac 要一直**醒着并且不锁屏**。睡眠、合盖、锁屏都会让它停下来。设置方法见[主 README](../README.md) 第 6 步。重启后要再双击一次 `muse-on.command`。

## 确认在工作

- 看日志：`tail -f muse-autoallow.log`。有请求时，2 分钟内会出现 `Allow pressed (ok): …`。
- 只跑一轮：`open -W -n ./MuseAutoAllow.app --args --once`

## 常见问题

| 问题 | 怎么办 |
|---|---|
| 日志写 `NOT TRUSTED` | 在辅助功能里删掉 `MuseAutoAllow`，重新添加并打开开关，然后双击 `muse-off.command` 和 `muse-on.command`。**每次重新编译或移动文件夹后都要做一次。** |
| 直接在终端运行程序时报 `NOT TRUSTED` | 要用 `muse-on.command` 或 `open` 启动，不要直接运行里面的程序。直接运行时，macOS 检查的是终端的权限，不是这个应用的。 |
| 日志写 `Muse not running` | 打开 Muse 桌面应用。 |
| 有请求但没被点 | Muse 是不是停在 Approvals 页面？Mac 锁屏或睡着了吗？ |
| 想看它能看到什么 | 运行 `open -W -n --stdout "$PWD/dump.txt" --stderr "$PWD/dump.txt" ./MuseAutoAllow.app --args --dump`，再 `cat dump.txt`，找 `AXButton … Allow`。 |

## 自定义

改 `MuseAutoAllow.swift`，再运行 `./build.sh`，然后重新给一次辅助功能权限：

- 开头的 `interval`（检查间隔，默认 120 秒）、`clickDelay`（每次点击间隔）、`maxClicksPerPass`（每轮最多点几个）。
- 只批准上传：在 `pass()` 里 `let (btn, title) = found[0]` 下面加一行 `if !title.lowercased().contains("upload") { break }`。排在最上面的非上传请求会停在那里等你处理。
- 如果你的 Muse 版本 bundle ID 不同，改 `fallbackBundleID`（应用会先按名字 "Muse" 查找）。

---

<a id="english"></a>

# Muse Auto Allow: Mac app

A small Mac app that runs in the background. When the Muse desktop app asks for approval (for example, to upload your resume), it clicks **Allow** for you.

- Checks every **2 minutes** and approves every waiting request, 2 seconds apart.
- Reads Muse's screen through macOS Accessibility. It doesn't move your mouse or take screenshots.
- ⚠️ It approves **every** request, not just uploads. To approve only uploads, see "Customize".

## Install (once)

1. Install Xcode Command Line Tools: run `xcode-select --install` in Terminal.
2. Download and build:
   ```
   git clone https://github.com/Dark417/muse-auto-job-apply
   cd muse-auto-job-apply/muse-auto-allow-mac
   ./build.sh
   ```
   This creates `MuseAutoAllow.app` in the same folder.
3. Give permission: System Settings → Privacy & Security → **Accessibility** → **+** → choose `MuseAutoAllow.app` from this folder → turn it **on**.

## Use

1. Open the Muse desktop app, open the **right-hand panel**, and click the **Approvals** tab (shield icon). You'll see the "Needs review" list. Leave it there.
2. Double-click **`muse-on.command`**. It runs in the background; you can close the Terminal window. If it's already running, you get an alert instead of a second copy.
3. To stop: double-click **`muse-off.command`**.

> ⚠️ **Muse must stay on the Approvals page.** If you close the panel, switch to Activity / Upcoming / Identity, or quit Muse, nothing gets clicked. The Muse window can be behind other windows.

> ⚠️ The Mac must stay **awake and unlocked**. Sleep, a closed lid, or a locked screen stops it. See Step 6 in the [main README](../README.en.md#step-6-keep-the-computer-awake). After a restart, double-click `muse-on.command` again.

## Check it's working

- Watch the log: `tail -f muse-autoallow.log`. When a request is waiting, you'll see `Allow pressed (ok): …` within 2 minutes.
- Run one pass only: `open -W -n ./MuseAutoAllow.app --args --once`

## Common problems

| Problem | What to do |
|---|---|
| Log says `NOT TRUSTED` | In Accessibility settings, remove `MuseAutoAllow`, add it again and turn it on. Then double-click `muse-off.command` and `muse-on.command`. **You need to do this after every rebuild or folder move.** |
| `NOT TRUSTED` when running the program from Terminal | Start it with `muse-on.command` or `open`, not by running the program inside the app directly. Run directly, macOS checks Terminal's permission instead of the app's. |
| Log says `Muse not running` | Open the Muse desktop app. |
| A request is waiting but nothing is clicked | Is Muse on the Approvals page? Is the Mac locked or asleep? |
| You want to see what the app sees | Run `open -W -n --stdout "$PWD/dump.txt" --stderr "$PWD/dump.txt" ./MuseAutoAllow.app --args --dump`, then `cat dump.txt` and look for `AXButton … Allow`. |

## Customize

Edit `MuseAutoAllow.swift`, run `./build.sh`, then give the Accessibility permission again:

- `interval` (time between checks, default 120 seconds), `clickDelay` (time between clicks) and `maxClicksPerPass` (most clicks per check) are at the top.
- To approve only uploads: in `pass()`, below `let (btn, title) = found[0]`, add `if !title.lowercased().contains("upload") { break }`. A non-upload request at the top then waits for you.
- If your Muse build has a different bundle ID, change `fallbackBundleID` (the app looks for "Muse" by name first).
