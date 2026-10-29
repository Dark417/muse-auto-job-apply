import Cocoa
import ApplicationServices

// Clicks "Allow" on every Muse approval prompt via the macOS Accessibility API
// (no mouse movement, no screenshots). Usage:
//   MuseAutoAllow            run forever, one pass every 2 minutes
//   MuseAutoAllow --once     single pass, then exit
//   MuseAutoAllow --dump     print Muse's accessibility tree (for debugging)

let fallbackBundleID = "com.meta.endo"   // Muse's bundle ID; the app is also looked up by name
let interval: TimeInterval = 120
let clickDelay: TimeInterval = 2
let maxClicksPerPass = 30

// The log lives next to the .app (MuseAutoAllow.app/Contents/MacOS/<exe> -> 4 levels up).
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
    let running = NSWorkspace.shared.runningApplications
    guard let app = running.first(where: { $0.localizedName == "Muse" })
            ?? running.first(where: { $0.bundleIdentifier == fallbackBundleID }) else { return nil }
    let el = AXUIElementCreateApplication(app.processIdentifier)
    // Make Chromium/Electron-style web content expose its tree.
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

/// Returns (button, promptTitle) for each Allow button. The title is only used for logging:
/// the nearest ancestor text that looks like "Allow <assistant> to ...".
func findAllowButtons(_ app: AXUIElement) -> [(AXUIElement, String)] {
    var buttons: [AXUIElement] = []
    walk(app) { e, _ in if isAllowButton(e) { buttons.append(e) } }
    return buttons.map { b in
        var cur: AXUIElement? = b
        for _ in 0..<8 {
            guard let c = cur, let p = attr(c, "AXParent") else { break }
            let parent = p as! AXUIElement
            if let t = allTexts(parent).first(where: { $0.hasPrefix("Allow ") && $0.count > 10 }) { return (b, t) }
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
    log("NOT TRUSTED: grant Accessibility to MuseAutoAllow.app in System Settings > Privacy & Security > Accessibility")
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
