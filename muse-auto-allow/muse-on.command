#!/bin/zsh
# Double-click to start MuseAutoAllow in the background. Alerts if it is already running.
DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$DIR/MuseAutoAllow.app"
PAT="MuseAutoAllow.app/Contents/MacOS/MuseAutoAllow"
[ -d "$APP" ] || "$DIR/build.sh" || { osascript -e 'display alert "Build failed" message "Run ./build.sh in Terminal to see the error." as critical'; exit 1; }
if pgrep -f "$PAT" >/dev/null; then
  osascript -e 'display alert "MuseAutoAllow is already running" message "Not starting a second copy." as warning'
  exit 0
fi
open -n "$APP"
sleep 2
if pgrep -f "$PAT" >/dev/null; then
  osascript -e 'display notification "Checking Muse every 2 minutes." with title "MuseAutoAllow started"'
else
  osascript -e 'display alert "MuseAutoAllow failed to start" message "Check muse-autoallow.log in the app folder." as critical'
fi
