import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Dictation indicator for the single pinned-language voxtype daemon
// (voxtype.service). Lit while the daemon is on -- red while recording,
// amber while transcribing -- and hidden with the other inactive indicators
// until hover when it is off. Click toggles the daemon; right click switches
// the Alt + Space chord between hold- and tap-to-speak. The hover label
// shows the pinned language (Norwegian/English), read from config.toml.

BarIndicator {
  id: root

  property string daemonState: "stopped"
  property string dictMode: "hold"

  readonly property string runDir: {
    const xdg = Quickshell.env("XDG_RUNTIME_DIR")
    return (xdg && xdg.length > 0) ? xdg : "/run/user/1000"
  }

  readonly property string stateDir: {
    const xdg = Quickshell.env("XDG_STATE_HOME")
    return (xdg && xdg.length > 0) ? xdg : Quickshell.env("HOME") + "/.local/state"
  }

  readonly property string configDir: {
    const xdg = Quickshell.env("XDG_CONFIG_HOME")
    return (xdg && xdg.length > 0) ? xdg : Quickshell.env("HOME") + "/.config"
  }

  property string dictLang: "no"

  readonly property bool anyOn: isOn(daemonState)

  readonly property string statusLine: "Dictation: " + stateLabel(daemonState)
      + " · " + langLabel() + " · " + (dictMode === "tap" ? "tap to speak" : "hold to speak")

  function stateColor(s) {
    if (s === "recording" || s === "streaming") return "#f2594d"
    if (s === "transcribing") return "#f2cc4d"
    return null
  }

  function isOn(s) {
    return s === "idle" || s === "recording" || s === "streaming" || s === "transcribing"
  }

  function stateLabel(s) {
    if (s === "recording" || s === "streaming") return "recording"
    if (s === "transcribing") return "transcribing"
    if (s === "idle") return "ready"
    return "off"
  }

  function langLabel() {
    return dictLang === "en" ? "English" : "Norwegian"
  }

  function parseLang(text) {
    const m = text.match(/^[ \t]*language[ \t]*=[ \t]*"(no|en)"/m)
    return m ? m[1] : "no"
  }

  active: anyOn
  activeText: "󰍬"
  inactiveText: "󰍭"
  activeTooltipText: statusLine + "\nClick: daemon off · Right: hold/tap mode"
  inactiveTooltipText: "Dictation: off · " + langLabel() + "\nClick: daemon on"

  useActiveColor: stateColor(daemonState) !== null
  activeColor: stateColor(daemonState) ?? "transparent"

  onPressed: function(b) {
    if (b === Qt.RightButton) {
      root.bar.run("voxtype-mode-toggle")
    } else if (b === Qt.LeftButton) {
      root.bar.run("voxtype-daemon-toggle")
    }
  }

  FileView {
    id: stateView
    path: root.runDir + "/voxtype/state"
    watchChanges: true
    printErrors: false
    onLoaded: root.daemonState = (text() || "stopped").trim()
    onLoadFailed: root.daemonState = "stopped"
    onFileChanged: reload()
  }

  FileView {
    id: modeView
    path: root.stateDir + "/voxtype/dictation-mode"
    watchChanges: true
    printErrors: false
    onLoaded: root.dictMode = (text() || "hold").trim()
    onLoadFailed: root.dictMode = "hold"
    onFileChanged: reload()
  }

  // The pinned language lives in config.toml (swapped by voxtype-lang);
  // watching the file keeps the hover label honest on every switch. The
  // config always exists, so no missing-file retry timer is needed.
  FileView {
    id: langView
    path: root.configDir + "/voxtype/config.toml"
    watchChanges: true
    printErrors: false
    onLoaded: root.dictLang = parseLang(text())
    onLoadFailed: root.dictLang = "no"
    onFileChanged: reload()
  }

  // FileView cannot watch a file that does not exist yet, so a daemon
  // started after the bar loaded would stay "off" forever. Retry the load
  // every few seconds while the state file is missing.
  Timer {
    interval: 3000
    repeat: true
    running: root.daemonState === "stopped"
    onTriggered: stateView.reload()
  }
}
