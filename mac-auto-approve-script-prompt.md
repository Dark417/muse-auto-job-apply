# Prompt: build "MuseAutoAllow", a background auto-approver for the Muse desktop app (macOS)

Paste everything below into an AI coding assistant that can run shell commands on your Mac (e.g. Claude Code). Tell it **which folder to build in** and any preferences (interval, log location). Replace `<PROJECT_DIR>` with that folder.

---

## Context

I use the **Muse** desktop app (a personal AI assistant) on my Mac. I have scheduled tasks (e.g. automatic job applying) that run inside Muse. Muse does not allow auto-approving certain actions, such as file uploads, so it pauses and shows an approval card in a right-hand panel:

- The panel has a header (assistant avatar and name, "Connected") and a row of 4 icon tabs. The 2nd tab (shield icon) is the approvals page, and it is the page I always leave open.
- Under a **"Needs review"** heading there is a list of 1..N pending items. The top item is expanded and shows its prompt text (e.g. "Allow Luna to upload this file using Browser for …?") with **Allow** and **Deny** buttons. When it is handled, the next item moves to the top and expands.
- Below that is an "Approvals history" section.

I have to click **Allow** by hand every time. I want a small local program that does it for me while I do other things.

## What to build

A native macOS background program (**Swift, single file, compiled with `swiftc`**, no dependencies) packaged as a minimal `.app` bundle in `<PROJECT_DIR>`. Everything stays inside `<PROJECT_DIR>`; don't write anywhere else, except one optional double-click launcher I describe below.

### Behavior
1. Every **120 seconds** do a "pass":
   - Find the running Muse app by its bundle ID. Don't assume it. Find it with `osascript -e 'id of app "Muse"'`, or inspect `/Applications/Muse.app/Contents/Info.plist`. On my machine it was `com.meta.endo`. If Muse isn't running, log it and wait for the next pass.
   - Read Muse's UI through the **macOS Accessibility API** (AXUIElement). No screenshots, no coordinates, no mouse movement and no fallback to simulated clicks. It must keep working regardless of window size or position, and I can keep using the Mac.
   - On the app element, set `AXManualAccessibility` and `AXEnhancedUserInterface` to true, so that Chromium/Electron-style web content exposes its tree.
   - Walk the tree (depth limit about 60) and find every `AXButton` whose title, description or value is exactly `Allow`.
   - For the title, climb up to 8 ancestors from the button. Take the first ancestor whose subtree text contains `Allow Luna to`. That text is the prompt title, used for logging only.
   - **Press the button with `AXUIElementPerformAction(button, kAXPressAction)`.** Click **every** Allow prompt regardless of its text. Don't filter by prompt type.
   - Wait **2 seconds**, re-scan, and repeat until no Allow button is left. Cap at **30 presses per pass**. Stop the pass if a press returns an error.
2. Append timestamped lines to `<PROJECT_DIR>/muse-autoallow.log`. Compute the path from the executable's location (4 directories up from `MuseAutoAllow.app/Contents/MacOS/MuseAutoAllow`), so moving the folder moves the log. Also print to stdout. Log lines:
   - `Allow pressed (ok): <prompt title>`
   - `Pass: nothing to approve`
   - `Muse not running`
   - `NOT TRUSTED: grant Accessibility to this app in System Settings > Privacy & Security > Accessibility`
   - `MuseAutoAllow started, interval 120s`
3. CLI modes: no args runs forever; `--once` does one pass and exits; `--dump` prints the Accessibility tree (indent by depth, skip empty `AXGroup`s) for debugging. On `--once` or `--dump`, exit 1 if not trusted.
4. The app bundle: `Info.plist` with `CFBundleIdentifier=local.muse.autoallow`, `CFBundleExecutable=MuseAutoAllow`, `LSUIElement=true` (no Dock icon). Ad-hoc sign it: `codesign --force --sign - --identifier local.muse.autoallow MuseAutoAllow.app`.
5. A `build.sh` that compiles, writes the Info.plist, signs, and (optionally) writes a launchd plist (`RunAtLoad`, `KeepAlive`) in `<PROJECT_DIR>` without loading it.
6. A double-click launcher `muse-on.command` (put it wherever I say, e.g. `~/Downloads`), `chmod +x`. It uses `.command` and not `.sh` because Finder opens `.sh` in a text editor. The launcher:
   - If `pgrep -f "MuseAutoAllow.app/Contents/MacOS/MuseAutoAllow"` finds a process, show `osascript` `display alert` "already running" and exit, so no second copy is started.
   - Otherwise run `open -n <PROJECT_DIR>/MuseAutoAllow.app`, wait 2 s, and show a notification "started", or an alert if it failed to start.

### Reference implementation (`MuseAutoAllow.swift`)

```swift
import Cocoa
import ApplicationServices

let bundleID = "com.meta.endo"          // CHANGE if Muse's bundle ID differs on your Mac
let interval: TimeInterval = 120
let clickDelay: TimeInterval = 2
let maxClicksPerPass = 30
let logPath = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent().appendingPathComponent("muse-autoallow.log").path

func log(_ s: String) {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let line = "\(f.string(from: Date())) \(s)\n"
    FileHandle.standardOutput.write(line.data(using: .utf8)!)
    if let h = FileHandle(forWritingAtPath: logPath) {
        h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); h.closeFile()
    } else {
        FileManager.default.createFile(atPath: logPath, contents: line.data(using: .utf8))
    }
}

func attr(_ e: AXUIElement, _ a: String) -> AnyObject? {
    var v: CFTypeRef?
    AXUIElementCopyAttributeValue(e, a as CFString, &v)
    return v
}
func children(_ e: AXUIElement) -> [AXUIElement] { (attr(e, "AXChildren") as? [AXUIElement]) ?? [] }
func role(_ e: AXUIElement) -> String { attr(e, "AXRole") as? String ?? "" }
func labels(_ e: AXUIElement) -> [String] {
    ["AXTitle", "AXDescription", "AXValue"].compactMap { attr(e, $0) as? String }.filter { !$0.isEmpty }
}
func walk(_ e: AXUIElement, depth: Int = 0, _ visit: (AXUIElement, Int) -> Void) {
    if depth > 60 { return }
    visit(e, depth)
    for c in children(e) { walk(c, depth: depth + 1, visit) }
}
func muse() -> AXUIElement? {
    guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first else { return nil }
    let el = AXUIElementCreateApplication(app.processIdentifier)
    AXUIElementSetAttributeValue(el, "AXManualAccessibility" as CFString, kCFBooleanTrue)
    AXUIElementSetAttributeValue(el, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue)
    return el
}
func allTexts(_ root: AXUIElement) -> [String] {
    var out: [String] = []
    walk(root) { e, _ in out += labels(e) }
    return out
}
func isAllowButton(_ e: AXUIElement) -> Bool {
    role(e) == "AXButton" && labels(e).contains { $0.trimmingCharacters(in: .whitespaces) == "Allow" }
}
func findAllowButtons(_ app: AXUIElement) -> [(AXUIElement, String)] {
    var buttons: [AXUIElement] = []
    walk(app) { e, _ in if isAllowButton(e) { buttons.append(e) } }
    return buttons.map { b in
        var cur: AXUIElement? = b
        for _ in 0..<8 {
            guard let c = cur, let p = attr(c, "AXParent") else { break }
            let parent = p as! AXUIElement
            if let t = allTexts(parent).first(where: { $0.contains("Allow Luna to") }) { return (b, t) }
            cur = parent
        }
        return (b, "")
    }
}
func pass() {
    guard let app = muse() else { log("Muse not running"); return }
    var clicks = 0
    while clicks < maxClicksPerPass {
        let found = findAllowButtons(app)
        if found.isEmpty { break }
        let (btn, title) = found[0]
        let r = AXUIElementPerformAction(btn, kAXPressAction as CFString)
        log("Allow pressed (\(r == .success ? "ok" : "AX error \(r.rawValue)")): \(title)")
        if r != .success { break }
        clicks += 1
        Thread.sleep(forTimeInterval: clickDelay)
    }
    if clicks == 0 { log("Pass: nothing to approve") }
}

let args = CommandLine.arguments
if !AXIsProcessTrusted() {
    log("NOT TRUSTED: grant Accessibility to this app in System Settings > Privacy & Security > Accessibility")
    if args.contains("--dump") || args.contains("--once") { exit(1) }
}
if args.contains("--dump") {
    guard let app = muse() else { print("Muse not running"); exit(1) }
    Thread.sleep(forTimeInterval: 1.5)
    walk(app) { e, d in
        let l = labels(e)
        if role(e) != "AXGroup" || !l.isEmpty {
            print(String(repeating: "  ", count: d) + role(e) + " " + l.joined(separator: " | "))
        }
    }
    exit(0)
}
if args.contains("--once") { pass(); exit(0) }
log("MuseAutoAllow started, interval \(Int(interval))s")
while true {
    pass()
    Thread.sleep(forTimeInterval: interval)
}
```

Adapt it if needed: the assistant's name ("Luna" on my Mac) and the exact prompt wording are specific to my setup. The "Allow Luna to" ancestor match is only used to label log lines, so use whatever your assistant's name is. If the button label isn't "Allow", adjust `isAllowButton` after checking the `--dump` output.

## Gotchas the AI must handle (learned the hard way)

- **Accessibility permission is attributed to the process that launched the program.** Running the binary directly from Terminal checks the *terminal's* permission, not the app's, so it shows `NOT TRUSTED` even though the app is enabled. Always test with `open -W -n --stdout <file> --stderr <file> ./MuseAutoAllow.app --args --dump` (and `--once`), which is also how the launcher starts it. Do not tell me to give Terminal Accessibility access.
- **Every rebuild re-signs the app and macOS drops the Accessibility grant.** After each `build.sh`, I must remove `MuseAutoAllow` from System Settings → Privacy & Security → Accessibility, add `<PROJECT_DIR>/MuseAutoAllow.app` again, switch it on, and restart the running copy. A running process does not pick up a newly granted permission. Tell me this each time the code is rebuilt.
- The AI can't grant the permission for me. It must tell me exactly what to click.
- Check that Muse exposes buttons with `--dump` before relying on it. You should see an `AXButton … Allow` line while an approval is pending. If you don't, stop and report it. Do not fall back to screenshots or mouse coordinates.

## Setup steps the AI should walk me through

1. Create the files in `<PROJECT_DIR>`, run `./build.sh`.
2. Tell me to add `<PROJECT_DIR>/MuseAutoAllow.app` under Accessibility and switch it on.
3. With Muse open on the shield tab, run `--dump` via `open` and confirm an Allow button appears (when something is pending).
4. Run `--once` via `open`, then `cat muse-autoallow.log` to confirm a press.
5. Create `muse-on.command` and tell me to double-click it. After that I can close the Terminal window; the app keeps running in the background.
6. Explain: stop it with `pkill -f MuseAutoAllow.app`, watch it with `tail -f <PROJECT_DIR>/muse-autoallow.log`, and after a reboot double-click `muse-on.command` again (or offer a launch-at-login option using the generated launchd plist; the plist holds absolute paths, so regenerate it with `build.sh` if the folder moves).

## Rules for my Mac

- The Mac must stay awake and unlocked, or the program can't read the screen. Closed lid, sleep and a locked screen all stop it. Suggest the relevant System Settings (prevent automatic sleeping on power adapter, display off but system awake, don't require a password after the display turns off), and make clear that this leaves the Mac unlocked.
- Keep Muse open on the approvals (shield) tab. Window size and position don't matter.

## Safety, tell me this up front

This clicks **Allow on every prompt Muse shows**, including sensitive ones (e.g. "Allow … to access <banking/crypto site>?"). If I only want file uploads auto-approved, add a filter so it presses only when the prompt title contains "upload", and skip others with a log line. Ask me which I want before finishing.
