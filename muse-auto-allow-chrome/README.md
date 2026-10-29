**English** | [中文](#中文)

# Muse Auto Allow: Chrome extension (Windows & Mac)

A Chrome extension that clicks **Allow** on Muse's "Needs review" approval prompts (e.g. file uploads) in the Muse web app, so scheduled Muse tasks never sit waiting for you.

It does the same job as the Mac app in [`../muse-auto-allow-mac/`](../muse-auto-allow-mac/), but runs in Chrome, so it works on **Windows and Mac**. There's nothing to build or grant at the system level.

- Every **2 minutes** it looks for open `https://muse.ai` tabs and clicks Allow on each pending card, **2 seconds** apart, until the list is empty (max 30 per pass).
- It only clicks buttons inside the **"Needs review"** section, and only on cards that show an "Allow … to …" prompt. Other "Allow" buttons on the page are ignored.
- Upload cards in the web app say **"Allow once"**; site-access cards say **"Allow"**. When a card has a dropdown next to "Allow once", it opens the dropdown and picks **"always allow for this website"**, so the same site doesn't ask again. If there's no dropdown or no such option, it just clicks "Allow once" / "Allow". The log shows which one it used, e.g. `Allow pressed: Allow Luna to upload … [Always allow for this website]`.
- **It clicks Allow on every prompt, including sensitive-site access.** See "Customize" to limit it to uploads.

## Install (once)

1. Get the code: `git clone https://github.com/Dark417/muse-auto-job-apply`, or on GitHub click **Code → Download ZIP** and unzip it.
2. In Chrome, open `chrome://extensions`.
3. Turn on **Developer mode** (top right).
4. Click **Load unpacked** and choose the **`muse-auto-allow-chrome`** folder (the one containing `manifest.json`).
5. Optional: click the puzzle icon in the toolbar and pin **Muse Auto Allow**.

It also works in other Chromium browsers (Edge, Brave, Arc) through their extensions page.

## Use it

1. In Chrome, open **https://muse.ai** and sign in.
2. Open the right-hand panel on the **Approvals (shield) tab**, where "Needs review" is listed. Leave the tab open. It can be in the background, but don't close it.

> **It only works while that tab stays on this page:** panel open, **Approvals** tab selected. If you close the panel or switch to Activity / Upcoming / Identity, nothing gets clicked, and the log says `sections 0`.
3. That's it. The extension checks every 2 minutes. The toolbar badge shows how many prompts it allowed in the last pass.

Click the extension icon to:
- switch it **on/off**,
- **Run now** (one pass immediately),
- see the **log** (last 200 lines), e.g. `Allow pressed: Allow Luna to upload this file…`.

## Keep it running

- **Chrome must stay open**, with the muse.ai tab open.
- **Stop Chrome from putting the tab to sleep:** Settings → **Performance** → **Always keep these sites active** → **Add** → `muse.ai`.
- **Keep the computer awake:**
  - **Windows:** Settings → System → **Power** (& battery) → set "When plugged in, put my device to sleep after" to **Never**. Locking the screen is fine; sleep is not.
  - **Mac:** see Step 6 in the [main README](../README.en.md#step-6-keep-the-computer-awake-forever).

## Update

`git pull` (or download the ZIP again), then on `chrome://extensions` click the **reload** ↻ icon on Muse Auto Allow.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Log says `No muse.ai tab open` | Open https://muse.ai in Chrome and keep that tab open. |
| Log says `Pass: nothing to approve`, but cards are waiting | The log line says why, e.g. `(tab visible, sections 0, Allow buttons on page 0)`. `sections 0` means the right panel isn't open on the approvals (shield) tab in that tab. Open it, then click **Run now**. |
| Nothing in the log for a long time | Is the extension switched on? Is the computer asleep? Did Chrome discard the tab (see "Keep it running")? |
| `Tab … error: …` | Reload the extension on `chrome://extensions`, then reload the muse.ai tab. |

## Customize

Edit `background.js`, then reload the extension:
- `INTERVAL_MIN`, `CLICK_DELAY_MS`, `MAX_CLICKS_PER_PASS` at the top change timing. Chrome won't run it more often than every 30 seconds.
- To click only uploads, in `findNext()` change `if (title)` to `if (title && /upload/i.test(title))`. A non-upload card at the top then waits for you.

## Files

| File | What it is |
|---|---|
| `manifest.json` | Extension manifest (Manifest V3). Only asks for access to `https://muse.ai/*`. |
| `background.js` | The timer and the click logic. |
| `popup.html`, `popup.js` | The on/off switch, Run now button and log. |

---

<a id="中文"></a>

# 中文

一个 Chrome 扩展：在 Muse 网页版里自动点"Needs review"审批列表的 **Allow**（比如上传文件的请求），让 Muse 的定时任务不会卡住等你。

和 [`../muse-auto-allow-mac/`](../muse-auto-allow-mac/) 里的 Mac 应用作用一样，但跑在 Chrome 里，所以 **Windows 和 Mac 都能用**，不用编译，也不用给系统权限。

- 每 **2 分钟**找一次打开着的 `https://muse.ai` 标签页，对每个待审批卡片点 Allow，每次间隔 **2 秒**，直到列表清空（每轮最多 30 个）。
- 只点 **"Needs review"** 区域里、而且卡片上有 "Allow … to …" 提示的按钮。页面上别的 "Allow" 按钮不会碰。
- 网页版里上传请求的按钮写的是 **"Allow once"**，访问网站的请求写的是 **"Allow"**，如果 "Allow once" 旁边有下拉菜单，它会打开下拉菜单，选 **"always allow for this website"（这个网站永远允许）**，同一个网站以后就不会再问。没有下拉菜单或没有这个选项时，就直接点 "Allow once" / "Allow"。日志里会写用的是哪一个，比如 `Allow pressed: Allow Luna to upload … [Always allow for this website]`。
- **它会对所有请求点 Allow，包括访问敏感网站的请求。** 只想批准上传的话，见下面"自定义"。

## 安装（只需一次）

1. 下载代码：`git clone https://github.com/Dark417/muse-auto-job-apply`，或者在 GitHub 上点 **Code → Download ZIP** 然后解压。
2. Chrome 打开 `chrome://extensions`。
3. 打开右上角的 **开发者模式（Developer mode）**。
4. 点 **加载已解压的扩展程序（Load unpacked）**，选择 **`muse-auto-allow-chrome`** 文件夹（里面有 `manifest.json` 的那个）。
5. 可选：点工具栏的拼图图标，把 **Muse Auto Allow** 固定到工具栏。

Edge、Brave、Arc 等基于 Chromium 的浏览器也能用，从它们自己的扩展页面加载即可。

## 使用

1. 在 Chrome 里打开 **https://muse.ai** 并登录。
2. 打开右侧面板的**审批页（Approvals，盾牌图标那个 tab）**，也就是显示 "Needs review" 的地方。这个标签页一直开着，可以放在后台，但不要关掉。

> **这个标签页必须一直停在这个页面才有效：** 面板打开、选中 **Approvals** tab。如果关掉面板，或者切到 Activity / Upcoming / Identity，就不会点，日志里会写 `sections 0`。
3. 就这样。扩展每 2 分钟检查一次，工具栏图标上的数字是上一轮批准了几个。

点扩展图标可以：
- **打开/关闭**，
- **Run now**（马上跑一轮），
- 看**日志**（最近 200 行），比如 `Allow pressed: Allow Luna to upload this file…`。

## 保持运行

- **Chrome 要一直开着**，muse.ai 标签页也要开着。
- **别让 Chrome 让这个标签页休眠：** 设置 → **性能（Performance）** → **始终让这些网站保持活动状态（Always keep these sites active）** → **添加** → `muse.ai`。
- **让电脑不睡眠：**
  - **Windows：** 设置 → 系统 → **电源**（和电池）→ "插入电源时，在此时间后使设备进入睡眠状态"设为**从不**。锁屏没关系，睡眠不行。
  - **Mac：** 见[主 README](../README.md) 第 6 步。

## 更新

`git pull`（或重新下载 ZIP），然后在 `chrome://extensions` 里点 Muse Auto Allow 上的**刷新** ↻ 图标。

## 常见问题

| 现象 | 解决办法 |
|---|---|
| 日志写 `No muse.ai tab open` | 在 Chrome 里打开 https://muse.ai 并保持这个标签页开着。 |
| 日志写 `Pass: nothing to approve`，但明明有卡片在等 | 日志后面会写原因，比如 `(tab visible, sections 0, Allow buttons on page 0)`。`sections 0` 表示那个标签页的右侧面板没停在审批页（盾牌 tab）。打开它，再点 **Run now**。 |
| 很久都没有日志 | 扩展是打开的吗？电脑睡着了吗？Chrome 是不是把标签页休眠了（见"保持运行"）？ |
| `Tab … error: …` | 在 `chrome://extensions` 里刷新扩展，再刷新 muse.ai 标签页。 |

## 自定义

改 `background.js`，然后刷新扩展：
- 开头的 `INTERVAL_MIN`、`CLICK_DELAY_MS`、`MAX_CLICKS_PER_PASS` 控制频率。Chrome 最快 30 秒跑一次。
- 只想点上传：在 `findNext()` 里把 `if (title)` 改成 `if (title && /upload/i.test(title))`。这样排在最上面的非上传请求会停在那里等你处理。
