**中文** | [English](#english)

# Muse Auto Allow：Chrome 扩展（Windows 和 Mac）

一个 Chrome 扩展。Muse 网页版（muse.ai）请求批准时（比如上传简历），它会自动帮你批准。不用编译，也不用给系统权限。

- 每 **2 分钟**检查一次打开着的 muse.ai 标签页，把所有待批准的请求都批准掉，每次间隔 2 秒。
- 如果 "Allow once" 旁边有下拉菜单，它会选 **"always allow for this website"（这个网站永远允许）**，同一个网站以后就不再问。没有这个选项时，就点 "Allow once" 或 "Allow"。
- 只点 "Needs review" 列表里的按钮，页面上别的 "Allow" 不会碰。
- ⚠️ 它会批准**所有**请求，不只是上传。只想批准上传，见下面"自定义"。

## 安装（只需一次）

1. 下载代码：`git clone https://github.com/Dark417/muse-auto-job-apply`，或者在 GitHub 上点 **Code → Download ZIP** 再解压。
2. Chrome 打开 `chrome://extensions`。
3. 打开右上角的**开发者模式**。
4. 点**加载已解压的扩展程序**，选 **`muse-auto-allow-chrome`** 文件夹（里面有 `manifest.json` 的那个）。
5. 可选：点工具栏的拼图图标，把 **Muse Auto Allow** 固定到工具栏。

Edge、Brave、Arc 等基于 Chromium 的浏览器也一样能用。

## 使用

1. 在 Chrome 里打开 https://muse.ai 并登录。
2. 打开**右侧面板**，点 **Approvals** 标签（盾牌图标），会看到 "Needs review" 列表。
3. 就停在这里，标签页不要关。它可以放在后台。

> ⚠️ **这个标签页必须一直停在 Approvals 页面。** 关掉面板、或者切到 Activity / Upcoming / Identity，就什么都不会点，日志里会写 `sections 0`。

点工具栏上的扩展图标，可以：
- **打开 / 关闭**扩展，
- **Run now**：马上检查一次，
- 看**日志**，比如 `Allow pressed: Allow Luna to upload … [Always allow for this website]`。方括号里是它选的选项。

工具栏图标上的数字，是上一次检查批准了几个。

## 保持运行

- **Chrome 和 muse.ai 标签页要一直开着。**
- **不让 Chrome 休眠这个标签页：** Chrome 设置 → **性能** → **始终让这些网站保持活动状态** → **添加** → `muse.ai`。
- **电脑不能睡眠：**
  - **Windows：** 设置 → 系统 → **电源** → 插电时睡眠设为**从不**。锁屏没关系。
  - **Mac：** 见[主 README](../README.md) 第 6 步。

## 更新

`git pull`（或重新下载 ZIP），然后在 `chrome://extensions` 里点 Muse Auto Allow 上的**刷新** ↻ 图标。

## 常见问题

| 日志里看到 | 怎么办 |
|---|---|
| `No muse.ai tab open` | 在 Chrome 里打开 https://muse.ai，标签页不要关。 |
| `Pass: nothing to approve (… sections 0 …)`，但明明有请求 | 那个标签页没停在 Approvals 页面。打开右侧面板，点 Approvals，然后点 **Run now**。 |
| 很久都没有新日志 | 扩展是打开的吗？电脑睡着了吗？Chrome 是不是让标签页休眠了（见"保持运行"）？ |
| `Tab … error: …` | 在 `chrome://extensions` 里刷新扩展，再刷新 muse.ai 标签页。 |
| 一直是 `[Allow once]`，从来没有 `[Always allow …]` | Muse 的下拉菜单里没有这个选项，或者名字不一样。可以先这样用；想改的话，看 `background.js` 里的 `allowAlways`。 |

## 自定义

改 `background.js`，然后在 `chrome://extensions` 里刷新扩展：
- 开头的 `INTERVAL_MIN`（检查间隔，分钟）、`CLICK_DELAY_MS`（每次点击间隔）、`MAX_CLICKS_PER_PASS`（每次最多点几个）。Chrome 最快 30 秒检查一次。
- 只批准上传：在 `findNext()` 里把 `if (title)` 改成 `if (title && /upload/i.test(title))`。排在最上面的非上传请求会停在那里等你处理。

## 文件

| 文件 | 是什么 |
|---|---|
| `manifest.json` | 扩展的配置。只请求访问 `https://muse.ai/*`。 |
| `background.js` | 定时器和点击逻辑。 |
| `popup.html`、`popup.js` | 开关、Run now 按钮和日志。 |

---

<a id="english"></a>

# Muse Auto Allow: Chrome extension (Windows and Mac)

A Chrome extension that approves Muse's requests on muse.ai (for example, uploading your resume) for you. Nothing to build, and no system permissions.

- Every **2 minutes** it checks your open muse.ai tabs and approves every waiting request, 2 seconds apart.
- If there's a dropdown next to "Allow once", it picks **"always allow for this website"**, so that site doesn't ask again. If that option isn't there, it clicks "Allow once" or "Allow".
- It only clicks buttons in the "Needs review" list. Other "Allow" buttons on the page are left alone.
- ⚠️ It approves **every** request, not just uploads. To approve only uploads, see "Customize".

## Install (once)

1. Download the code: `git clone https://github.com/Dark417/muse-auto-job-apply`, or on GitHub click **Code → Download ZIP** and unzip.
2. In Chrome, go to `chrome://extensions`.
3. Turn on **Developer mode** (top right).
4. Click **Load unpacked** and choose the **`muse-auto-allow-chrome`** folder (the one with `manifest.json`).
5. Optional: click the puzzle icon in the toolbar and pin **Muse Auto Allow**.

It also works in other Chromium browsers like Edge, Brave and Arc.

## Use

1. Open https://muse.ai in Chrome and sign in.
2. Open the **right-hand panel** and click the **Approvals** tab (shield icon). You'll see the "Needs review" list.
3. Leave it there and keep the tab open. It can be in the background.

> ⚠️ **The tab must stay on the Approvals page.** If you close the panel or switch to Activity / Upcoming / Identity, nothing gets clicked, and the log says `sections 0`.

Click the extension's toolbar icon to:
- turn it **on / off**,
- **Run now**: check right away,
- see the **log**, e.g. `Allow pressed: Allow Luna to upload … [Always allow for this website]`. The part in brackets is the option it chose.

The number on the toolbar icon is how many requests it approved in the last check.

## Keep it running

- **Keep Chrome and the muse.ai tab open.**
- **Stop Chrome from putting the tab to sleep:** Chrome Settings → **Performance** → **Always keep these sites active** → **Add** → `muse.ai`.
- **Don't let the computer sleep:**
  - **Windows:** Settings → System → **Power** → when plugged in, sleep after **Never**. A locked screen is fine.
  - **Mac:** see Step 6 in the [main README](../README.en.md#step-6-keep-the-computer-awake).

## Update

`git pull` (or download the ZIP again), then click the **reload** ↻ icon on Muse Auto Allow at `chrome://extensions`.

## Common problems

| The log says | What to do |
|---|---|
| `No muse.ai tab open` | Open https://muse.ai in Chrome and keep the tab open. |
| `Pass: nothing to approve (… sections 0 …)`, but requests are waiting | That tab isn't on the Approvals page. Open the right-hand panel, click Approvals, then click **Run now**. |
| Nothing new for a long time | Is the extension on? Is the computer asleep? Did Chrome put the tab to sleep (see "Keep it running")? |
| `Tab … error: …` | Reload the extension at `chrome://extensions`, then reload the muse.ai tab. |
| Always `[Allow once]`, never `[Always allow …]` | Muse's dropdown doesn't have that option, or it's named differently. It still works; to change the match, see `allowAlways` in `background.js`. |

## Customize

Edit `background.js`, then reload the extension at `chrome://extensions`:
- `INTERVAL_MIN` (minutes between checks), `CLICK_DELAY_MS` (time between clicks) and `MAX_CLICKS_PER_PASS` (most clicks per check) are at the top. Chrome won't check more often than every 30 seconds.
- To approve only uploads: in `findNext()`, change `if (title)` to `if (title && /upload/i.test(title))`. A non-upload request at the top then waits for you.

## Files

| File | What it is |
|---|---|
| `manifest.json` | Extension settings. Only asks for access to `https://muse.ai/*`. |
| `background.js` | The timer and the clicking. |
| `popup.html`, `popup.js` | The on/off switch, Run now button and log. |
