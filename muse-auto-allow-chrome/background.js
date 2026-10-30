// Every INTERVAL minutes, allows every pending approval in open muse.ai tabs
// ("always allow for this website" when the card offers it).

const INTERVAL_MIN = 2;
const CLICK_DELAY_MS = 2000;
const MAX_CLICKS_PER_PASS = 30;
const MUSE_URLS = ["https://muse.ai/*"];
const LOG_LIMIT = 200;

// Runs every time the service worker starts; only creates what is missing.
setup();

async function setup() {
  const { enabled } = await chrome.storage.local.get("enabled");
  if (enabled === undefined) await chrome.storage.local.set({ enabled: true });
  if (!(await chrome.alarms.get("pass"))) {
    await chrome.alarms.create("pass", { periodInMinutes: INTERVAL_MIN, delayInMinutes: 0.1 });
  }
}

chrome.alarms.onAlarm.addListener(async (alarm) => {
  if (alarm.name !== "pass") return;
  const { enabled } = await chrome.storage.local.get("enabled");
  if (enabled) await pass();
});

chrome.runtime.onMessage.addListener((msg, _sender, reply) => {
  if (msg === "runNow") { pass().then(reply); return true; }
});

async function pass() {
  const tabs = await chrome.tabs.query({ url: MUSE_URLS });
  if (tabs.length === 0) return log("No muse.ai tab open");
  let total = 0;
  for (const tab of tabs) {
    try {
      const [res] = await chrome.scripting.executeScript({
        target: { tabId: tab.id },
        func: clickAllowButtons,
        args: [CLICK_DELAY_MS, MAX_CLICKS_PER_PASS],
      });
      const { pressed = [], diag } = res.result || {};
      for (const title of pressed) await log(`Allow pressed: ${title}`);
      total += pressed.length;
      if (!pressed.length) await log(`Pass: nothing to approve (${diag})`);
    } catch (e) {
      await log(`Tab ${tab.id} error: ${e.message}`);
    }
  }
  await chrome.action.setBadgeText({ text: total ? String(total) : "" });
}

async function log(line) {
  const { logs = [] } = await chrome.storage.local.get("logs");
  logs.unshift(`${new Date().toLocaleString()}  ${line}`);
  await chrome.storage.local.set({ logs: logs.slice(0, LOG_LIMIT) });
}

// Runs inside the muse.ai page. Must be self-contained (no outer variables).
async function clickAllowButtons(delayMs, maxClicks) {
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const text = (el) => (el.innerText || el.textContent || "").trim();
  // Site-access cards say "Allow"; upload cards in the web app say "Allow once",
  // which always comes with a dropdown holding "Always allow" (used instead).
  const allowButtons = (root) =>
    [...root.querySelectorAll("button, [role=button]")].filter(
      (b) => /^Allow( once)?$/.test(text(b)) && !b.disabled && b.getAttribute("aria-disabled") !== "true");

  // Search only inside the "Needs review" section. Muse labels it
  // aria-label="Needs review"; if that label is missing, fall back to the
  // heading's nearest enclosing block (at most MAX_UP levels up).
  const MAX_UP = 3;
  const scopes = () => {
    const labeled = [...document.querySelectorAll('[aria-label="Needs review"]')];
    if (labeled.length) return labeled;
    const out = [];
    for (const h of document.querySelectorAll("h1,h2,h3,h4,h5,h6,[role=heading],span,div,p")) {
      if (h.children.length > 1 || text(h) !== "Needs review") continue;
      let box = h.parentElement, up = 1;
      while (box && text(box) === "Needs review") { box = box.parentElement; up++; }
      if (box && up <= MAX_UP) out.push(box);
    }
    return out;
  };
  // A real card shows an "Allow <assistant> to …" prompt between its button and the section.
  const findNext = () => {
    for (const scope of scopes()) {
      for (const btn of allowButtons(scope)) {
        for (let el = btn.parentElement; el && el !== scope.parentElement; el = el.parentElement) {
          const title = text(el).split("\n").map((s) => s.trim()).find((s) => /^Allow .+ to /.test(s));
          if (title) return { btn, title };
        }
      }
    }
    return null;
  };

  // A real press: menus that open on pointerdown (e.g. Radix) ignore a bare click().
  const press = (el) => {
    const o = { bubbles: true, cancelable: true, view: window, button: 0, pointerType: "mouse", isPrimary: true };
    el.dispatchEvent(new PointerEvent("pointerdown", o));
    el.dispatchEvent(new MouseEvent("mousedown", o));
    el.dispatchEvent(new PointerEvent("pointerup", o));
    el.dispatchEvent(new MouseEvent("mouseup", o));
    el.click();
  };
  const visible = (el) => el.offsetParent !== null || el.getClientRects().length > 0;

  // The dropdown toggle that sits next to an "Allow once" button.
  const findToggle = (btn) => {
    for (let el = btn.parentElement, up = 0; el && up < 4; el = el.parentElement, up++) {
      const t = el.querySelector('[data-pel-click="chat_inline_approval_allow_options_menu_open"]') ||
        [...el.querySelectorAll("button, [role=button]")].find((b) => b !== btn && b.getAttribute("aria-haspopup"));
      if (t) return t;
    }
    return null;
  };

  // "Allow once" means there's a dropdown: open it and click "Always allow".
  // Returns the option's text, or null (menu closed again) if it can't be found.
  const allowAlways = async (btn) => {
    const toggle = findToggle(btn);
    if (!toggle) return null;
    const before = new Set(document.querySelectorAll("*"));  // menu items are new elements
    press(toggle);
    let option = null;
    for (let waited = 0; waited < 3000 && !option; waited += 200) {
      await sleep(200);
      const items = [...document.querySelectorAll('[role^=menuitem], [role=option], button, li, a, div, span')]
        .filter((el) => !before.has(el) && visible(el))
        .filter((el) => { const s = text(el); return s.length < 80 && !s.includes("\n") && /always/i.test(s); });
      // Prefer an item that starts with "Always allow"; take the innermost element, not its wrapper.
      const best = items.filter((el) => /^always allow/i.test(text(el)));
      const pool = best.length ? best : items;
      option = pool.find((el) => !pool.some((o) => o !== el && el.contains(o))) || null;
    }
    if (!option) {
      document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
      await sleep(300);
      return null;
    }
    const label = text(option);
    press(option.closest('[role^=menuitem], [role=option], button, li, a') || option);
    return label;
  };

  const pressed = [];
  let last = null;
  while (pressed.length < maxClicks) {
    const next = findNext();
    if (!next || next.btn === last) break;  // nothing left, or the click didn't take
    let how = null;
    if (/^Allow once$/.test(text(next.btn))) {
      how = await allowAlways(next.btn);
      // Couldn't find "Always allow": approve once rather than leave Muse stuck.
      if (!how) { press(next.btn); how = "Allow once (no Always allow found)"; }
    } else {
      press(next.btn);
      how = text(next.btn);
    }
    pressed.push(`${next.title} [${how}]`);
    last = next.btn;
    await sleep(delayMs);
  }
  const diag = `tab ${document.visibilityState}, sections ${scopes().length}, ` +
    `Allow buttons on page ${allowButtons(document).length}`;
  return { pressed, diag };
}
