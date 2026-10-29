# Muse auto job apply

## Quick start: the auto-approve app

[`muse-auto-allow/`](muse-auto-allow/) is a ready-to-build Mac app that clicks Allow on Muse's approval prompts for you.

```
git clone https://github.com/Dark417/muse-auto-job-apply
cd muse-auto-job-apply/muse-auto-allow
./build.sh
```

Then add `muse-auto-allow/MuseAutoAllow.app` under System Settings → Privacy & Security → Accessibility and switch it on. After that, double-click `muse-on.command` to start it (`muse-off.command` stops it). Full instructions are in [muse-auto-allow/README.md](muse-auto-allow/README.md). Prefer to have an AI generate it for you? Use the prompt in `mac-auto-approve-script-prompt.md` (section 3 below).

---

Three prompts that together run a hands-off job-application pipeline on a Mac that stays on:

| # | File | Runs in | What it does |
|---|------|---------|--------------|
| 1 | [muse-prompt.md](muse-prompt.md) | **Muse** (your personal assistant app) | The operating manual for the assistant: it sources jobs, applies, tracks every application in one log and spreadsheet, and reports. Replace the `[PLACEHOLDERS]` with your details, then give it to Muse. |
| 2 | [claude-job-email-verifier.md](claude-job-email-verifier.md) | **Claude** (scheduled task) | Every hour it checks your application Gmail for "verify your email / activate your account" messages from job sites, opens each link once in your browser, and labels the email so it's never opened twice. |
| 3 | [mac-auto-approve-script-prompt.md](mac-auto-approve-script-prompt.md) | **An AI coding assistant on your Mac** (e.g. Claude Code) | Has the AI build a small background Mac program that clicks **Allow** on Muse's approval prompts (such as file uploads), which Muse won't auto-approve. |

## How the pieces fit

1. **Muse** does the applying. It stops and asks for approval on some steps, mainly file uploads.
2. **The Mac script (3)** clicks Allow for you, so Muse never sits waiting.
3. **Claude (2)** verifies the accounts that job sites create, so applications don't stall on unverified emails.

## Before you start: log in to your email in both apps

Use one **dedicated job-application Gmail**, not your personal inbox.

- **In Muse:** connect that Gmail through Muse's email connector, so it can read confirmations, verification codes, rejections and interview invites. See Part 6 of `muse-prompt.md`.
- **In Claude:** connect the same Gmail under Settings → Connectors → Gmail. The email verifier (2) needs it. Also sign in to that Gmail in the browser Claude will drive.

Never paste passwords into prompts or chats. Each prompt says where credentials belong.

## Setup, step by step

### 1. Set up Muse
1. Open `muse-prompt.md`, fill in every `[PLACEHOLDER]`, and give it to Muse as its instructions.
2. Connect the application Gmail in Muse and check that it can read the inbox.
3. Create your scheduled job tasks in Muse as the guide describes.

### 2. Set up the Claude email verifier
1. Connect Gmail in Claude, as above.
2. Install a browser Claude can drive (Claude in Chrome, or the Claude desktop app).
3. Create a scheduled task that runs every hour and paste the prompt from `claude-job-email-verifier.md` (replace `<YOUR_JOB_APP_GMAIL>` and `<YOUR_AGENT_NAME>`). Turn on automatic approval and "require this computer".

### 3. Build the Mac auto-approve script
1. On the Mac that will stay on, open an AI coding assistant that can run shell commands (e.g. Claude Code) in an empty folder.
2. Paste the whole of `mac-auto-approve-script-prompt.md`, replacing `<PROJECT_DIR>` with that folder. The AI writes the Swift program, builds it, and creates a double-click launcher (`muse-on.command`).
3. **Grant Accessibility permission** when the AI asks: System Settings → Privacy & Security → Accessibility → add `MuseAutoAllow.app` and switch it on. Do this again after every rebuild.
4. Open Muse on the approvals (shield) tab and leave it there. Double-click `muse-on.command`. You can then close the Terminal window.
5. Check the log (`muse-autoallow.log` in the folder). With a pending approval you should see `Allow pressed (ok): …` within 2 minutes.

Note: this script clicks Allow on **every** Muse prompt by default, including sensitive-site access. The prompt tells the AI to ask whether you want that restricted to uploads.

### 4. Keep the Mac on forever
The script can't click on a sleeping or locked Mac. In System Settings:
- Keep the Mac **plugged in**, with the lid open (or an external monitor connected).
- Under Battery/Energy, turn on **"Prevent automatic sleeping on power adapter when the display is off"**, or set sleep to Never.
- Under Lock Screen, set **"Require password after screen saver begins or display is turned off"** to **Never**. A locked screen blocks the clicking, and this leaves your Mac unlocked, so use it only somewhere you trust.
- The display can turn off or be dimmed. The system just has to stay awake.
- After a reboot, double-click `muse-on.command` again.

## Stop everything
- Mac script: `pkill -f MuseAutoAllow.app`
- Claude verifier: pause or delete the scheduled task in Claude.
- Muse: pause its scheduled tasks in the app.
