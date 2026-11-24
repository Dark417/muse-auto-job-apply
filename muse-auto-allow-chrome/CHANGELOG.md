# Changelog

All notable changes to the Muse Auto Allow Chrome extension are documented here, newest first.

## 1.3.0

- Check interval: `2 minutes` → `30 seconds` (`INTERVAL_MIN` from `2` to `0.5`, Chrome's fastest allowed alarm period).
- Click delay is now randomized `0.5–1s` instead of a fixed `2s`, via new `CLICK_DELAY_MIN_MS` / `CLICK_DELAY_MAX_MS` constants (replacing `CLICK_DELAY_MS`).

## 1.2.0

- "Allow once" now always goes through the dropdown's "Always allow" option instead of clicking "Allow once" directly, so the same site doesn't keep asking.

## 1.1.0

- Added picking "Always allow for this website" from the Allow dropdown menu.

## 1.0.0

- Initial release: clicks "Allow" on Muse's "Needs review" approval prompts in an open muse.ai tab, every 2 minutes.
