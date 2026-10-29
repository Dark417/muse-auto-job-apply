const $ = (id) => document.getElementById(id);

async function render() {
  const { enabled, logs = [] } = await chrome.storage.local.get(["enabled", "logs"]);
  $("enabled").checked = enabled !== false;
  $("log").textContent = logs.join("\n") || "(no activity yet)";
}

$("enabled").onchange = (e) => chrome.storage.local.set({ enabled: e.target.checked });
$("run").onclick = async () => {
  $("run").disabled = true;
  await chrome.runtime.sendMessage("runNow");
  $("run").disabled = false;
  render();
};
$("clear").onclick = async () => { await chrome.storage.local.set({ logs: [] }); render(); };

render();
