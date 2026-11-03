**中文** | [English](README.en.md)

# Muse 自动投简历

让 **Muse**（https://muse.ai 上的 AI 助手）按你的要求，24 小时自动帮你投简历。

**任何专业都能用**，不只是程序员：你告诉 Muse 要找什么职位名称、什么级别、哪些关键词要过滤掉。

**我们在干什么，用最简单的话说：**

1. **设置一次 Muse**：填好说明书文件，上传简历。之后 Muse 就按你的要求自动找职位、自动投递。
2. **安装 Chrome 插件，电脑一直开着**：插件会在上传简历时自动点允许按钮（Allow once / Allow），上传不会卡住等你。
3. **验证链接每小时点一次**：招聘网站发来的"点链接验证账号"邮件，由每小时跑一次的定时任务去点。Muse 一收到就立刻去点，还没有设置好。

---

## 这套东西是怎么想的（大意）

细节全在 [muse-prompt.md](muse-prompt.md) 里。这里是大意，和最需要注意的几点：

- **先投最新的职位。** LinkedIn 上的职位按 12 → 24 → 36 → 48 小时一层层找，48 小时是上限；公司官网上的职位没有时间限制，按最新到最旧投。
- **投得多，但只投真正合适的。** 职位名称、级别、薪资、签证情况都要对得上，不乱投。
- **在公司官网投递。** LinkedIn 只用来找职位，不用 "Easy Apply"。
- **按类别直接去公司官网投。** 不只从 LinkedIn 找职位，也直接去公司官网投递，按类别分：大公司、金融科技（fintech）、量化（quant）、银行。
- **上传不用你守着。** Chrome 插件 + 一直开着的电脑会自动点上传的允许按钮，卡住也只等几分钟。
- **不编、不猜。** 不知道怎么回答的问题，会停下来问你。
- **不重复投。** 所有申请都记在一个表格里，投之前先查，同一个职位（公司 + 职位 + 编号）绝不投两次。
- **不卡住。** 一个申请超过 1 小时还没完成，就先放一边，接着投下一个。
- **验证题直接退出。** 网站弹出滑块、点选验证之类的，直接退出、记下来、关掉标签页，不硬闯、不重试。
- **登录墙不是失败。** 需要注册账号、收验证码、点验证链接，都是正常步骤，不是失败原因。
- **主动联系人。** 职位上写了招聘负责人的，会在 LinkedIn 上发一条简短的加好友留言。

完整版在 `muse-prompt.md` 开头的 "How this system thinks" 部分。

---

## 设置步骤（照着做）

**准备好：**

- **简历** PDF。
- **求职信（cover letter）** PDF（可选）。
- 一个**只用来求职的 Gmail**。最好新建一个，这样求职邮件不会和私人邮件混在一起。

**第 1 步：拿到说明书文件**

1. 打开说明书文件：**[muse-prompt.md](muse-prompt.md)**。
2. 下载它：点文件右上角的**下载按钮**（向下的箭头 ⬇）。

**第 2 步：填两个框（最关键的一步）**

3. 打开下载好的文件：
   - **Windows：** 右键 → **打开方式** → **记事本**。
   - **Mac：** 右键 → **打开方式** → **文本编辑**。
4. 在文件最上面的 **✏️ STEP 1: FILL IN YOUR INFORMATION HERE** 下面有两个框。把每一个 **`____`** 换成你自己的信息。只需要填这两个框，文件里别的地方都不用改：
   - **Box A：关于你。** 姓名、邮箱、电话、学历、工作年限、签证情况等。
   - **Box B：投什么工作。** 关键词都在这里，填法如下：
     - `[TARGET_TITLES]`：想投的职位名称，写好几个，用逗号分开。公司对同一个职位叫法不同，比如：
       ```
       [TARGET_TITLES]  = Data Analyst, Business Analyst, BI Analyst
       ```
     - `[BACKUP_TITLES]`：备选职位名称，主力职位投完以后用，比如 `Reporting Analyst, Operations Analyst`。
     - `[TARGET_LEVELS]`：级别，比如 `junior, mid-level` 或 `mid-level, senior`。
     - `[SKIP_KEYWORDS]`：过滤词。职位名称里带这些词的，一律跳过。比如：
       ```
       [SKIP_KEYWORDS]  = senior, staff, principal, manager, intern, internship
       ```
       - 有几年经验？过滤掉 `principal, staff, director, intern, internship, new grad, graduate, lead`。
       - 学生或应届生？过滤掉 `senior, staff, principal, lead, manager`。
     - `[MAX_YEARS_REQUIRED]`：职位要求年限超过这个数就跳过。可以比你真实年限写高一点（比如你有 3 年，写 5）。
     - `[MUST_HAVE_KEYWORDS]`：好职位通常会提到的词，比如 `Python, SQL`；没有就写 `none`。
     - `[TARGET_LOCATIONS]`：想去的地方，比如 `anywhere in the US`、`remote only`、`Bay Area, Seattle`。
     - `[YOUR_COMP_FLOOR]`：最低年薪，比如 `$130k`；不确定就写 `any`。写太高会没职位可投。
     - `[YOUR_DO_NOT_APPLY_LIST]`：永远不投的公司，没有就写 `none`。

     Box B 下面有**现成的例子**：程序员、应届生、数据分析、市场营销、机械工程、实习。挑一个最接近你的，复制过来再改。

**第 3 步：把文件交给 Muse**

5. **保存**文件。
6. 打开 **https://muse.ai** 并登录，开一个**新对话**。
7. 上传 **3 个文件**：填好的 `muse-prompt.md`、简历 PDF、求职信 PDF。
8. 复制下面这段话，**粘贴到对话里**发给 Muse：
   > Read muse-prompt.md. These are your rules for applying to jobs for me. My resume and cover letter are attached. Set up the scheduled job-application tasks described in Part 1, then walk me through the setup checklist in Part 6.9.
9. Muse 会请你**连接求职 Gmail**、**保存各个招聘网站的登录信息**。按它说的做就行。

> 🔒 不要在聊天里输入密码。需要密码时，Muse 会弹出一个安全的输入框。

**第 4 步：安装 Chrome 插件，电脑一直开着**

- 安装仓库里的 Chrome 插件（`muse-auto-allow-chrome/`）。
- 电脑保持开机。插件会在上传简历时自动点 **Allow once** / **Allow**，你不用守着点。

**第 5 步：放着让它跑**

- Muse 会按短周期一直找职位、投递，你不用守着看。
- 只有几件事需要你：点验证链接、做 Muse 拿不准的选择、回它的问题。其他时间不用管。
- 想停就停：在 Muse 里暂停它的定时任务。

---

## 遇到问题？

| 你看到的 | 怎么办 |
|---|---|
| Muse 说找不到验证码 | 确认 Muse 连的是你的**求职** Gmail。如果网站是发短信，看下面的"把短信验证码转发到 Gmail"。 |
| 一整天都没有新投递 | Muse 只找最新的职位（LinkedIn 48 小时以内，公司官网按最新到最旧）。跟 Muse 说放宽范围，比如 "look at jobs from the last 72 hours"（`muse-prompt.md` 第 3.2 节）。 |

**全部停止：** 在 Muse 里暂停它的定时任务。

---

## 可选的额外功能

刚开始用不到，以后需要再加。

<details>
<summary><b>自动打开"验证邮箱"链接（Claude）</b></summary>

有些招聘网站会发一封带链接的邮件，比如"点击验证你的账号"。Muse 打不开这种链接，Claude 桌面应用可以每小时帮你打开。

1. 打开 [claude-job-email-verifier.md](claude-job-email-verifier.md)，把 `<YOUR_JOB_APP_GMAIL>` 换成你的求职 Gmail，把 `<YOUR_AGENT_NAME>` 换成 `Muse`。
2. 在 **Claude** 桌面应用里：设置 → **Connectors** → **Gmail** → 连接求职 Gmail。
3. 在 Claude 聊天里输入：_"create a scheduled task that runs every hour with this prompt"_，再把那个文件第 2 节的内容粘贴进去。
4. 给这个任务打开 **Automatically approve** 和 **Require this computer**。
5. 自己先手动跑一次，它要打开招聘网站时点 **Allow**。

验证过的邮件在 Gmail 里会带 `ats-verified` 标签。
</details>

<details>
<summary><b>把短信验证码转发到 Gmail（iPhone）</b></summary>

有些网站用短信发验证码。Muse 只能读邮件，所以让 iPhone 把这些短信转成邮件。

1. iPhone → **快捷指令** App → **自动化** → **+** → **信息**。
2. **信息包含**：`code` → 选**立即运行** → **下一步**。
3. 添加操作**发送电子邮件**：
   - 收件人：你的求职 Gmail。
   - 主题：`SMS code`。
   - 正文：点一下 → 选 **快捷指令输入 → 内容**。
   - 点这个操作上的小箭头，**关掉**"显示撰写表单"。
4. 对其他关键词（比如 `verification`、`验证码`）各做一个。
5. 测试：让一个网站给你发短信验证码，看邮件有没有到。
</details>
