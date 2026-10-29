#!/bin/zsh
# Compiles MuseAutoAllow.app into this folder. Needs Xcode Command Line Tools (xcode-select --install).
set -e
cd "$(dirname "$0")"
APP="$PWD/MuseAutoAllow.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
swiftc -O MuseAutoAllow.swift -o "$APP/Contents/MacOS/MuseAutoAllow"
cat > "$APP/Contents/Info.plist" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.muse.autoallow</string>
<key>CFBundleName</key><string>MuseAutoAllow</string>
<key>CFBundleExecutable</key><string>MuseAutoAllow</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
PL
codesign --force --sign - --identifier local.muse.autoallow "$APP"
echo "Built $APP"
echo "Next: System Settings > Privacy & Security > Accessibility > + > add this app and switch it on,"
echo "then double-click muse-on.command."
