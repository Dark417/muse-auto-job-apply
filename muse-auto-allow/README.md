# MuseAutoAllow

A tiny background Mac app that clicks **Allow** on the Muse desktop app's approval prompts (e.g. file uploads), so scheduled Muse tasks never sit waiting for you.

- Reads Muse's UI through the macOS Accessibility API and presses the Allow button. It doesn't move your mouse, take screenshots or care about window size.
- Checks every 2 minutes. Each pass clicks Allow on every pending prompt, 2 seconds apart, until the list is empty.
- **It clicks Allow on every prompt, including sensitive-site access ones.** If you want only uploads, change the code (see "Customize").

## Requirements
- macOS with Xcode Command Line Tools: `xcode-select --install`
- Muse installed. Leave it open on the approvals (shield) tab.

## Use it (once)
1. Download this folder (`git clone https://github.com/Dark417/muse-auto-job-apply` or the zip) and open it in Terminal: `cd muse-auto-job-apply/muse-auto-allow`
2. Build: `./build.sh` (creates `MuseAutoAllow.app` right here; it is built on your Mac, so nothing is downloaded or pre-compiled).
3. **Grant permission, once:** System Settings → Privacy & Security → Accessibility → **+** → pick the `MuseAutoAllow.app` in this folder → switch it **on**.
4. Double-click **`muse-on.command`**. It starts the app in the background and you can close the Terminal window. If it's already running, you get an alert instead of a second copy.

To stop it, double-click `muse-off.command`.

## Check it works
- `tail -f muse-autoallow.log` (the log is created next to the app). With an approval pending you should see `Allow pressed (ok): …` within 2 minutes.
- Debug what the app can see: `open -W -n --stdout "$PWD/dump.txt" --stderr "$PWD/dump.txt" ./MuseAutoAllow.app --args --dump` then `cat dump.txt` (look for `AXButton … Allow`).
- One pass only: `open -W -n ./MuseAutoAllow.app --args --once`

## Gotchas
- Run it with `open` or the launcher, **not** by executing the binary in Terminal. Run that way, macOS checks the Terminal's permission instead of the app's and says `NOT TRUSTED`.
- **Every rebuild (or moving the folder) drops the Accessibility grant.** Remove `MuseAutoAllow` from the Accessibility list, add the app again, switch it on, then restart it (`muse-off.command`, `muse-on.command`).
- The Mac must stay **awake and unlocked**. Sleep, a closed lid and a locked screen all stop it. See the top-level README for the settings.
- After a reboot, double-click `muse-on.command` again.

## Customize
Edit `MuseAutoAllow.swift`, then run `./build.sh` and redo the permission step:
- `interval`, `clickDelay`, `maxClicksPerPass` at the top change timing.
- To click only uploads, in `pass()` skip when `!title.lowercased().contains("upload")`.
- If your Muse build uses a different bundle ID, change `fallbackBundleID` (the app is first found by the name "Muse").
