#!/bin/zsh
# Double-click to stop MuseAutoAllow.
if pkill -f "MuseAutoAllow.app/Contents/MacOS/MuseAutoAllow"; then
  osascript -e 'display notification "Stopped." with title "MuseAutoAllow"'
else
  osascript -e 'display alert "MuseAutoAllow is not running"'
fi
