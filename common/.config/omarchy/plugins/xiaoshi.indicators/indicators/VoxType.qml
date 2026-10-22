import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Dictation indicator for the two voxtype daemons:
//   N = Norwegian (voxtype.service)        E = English (voxtype-english.service)
// Lit when either daemon is on (red = recording, amber = transcribing),
// dimmed and only revealed on hover when both are off — like the other
// indicators. Click activates English when off, otherwise turns all off.

BarIndicator {
  id: root

  property string noState: "stopped"
  property string enState: "stopped"

  readonly property string runDir: {
    const xdg = Quickshell.env("XDG_RUNTIME_DIR")
    return (xdg && xdg.length > 0) ? xdg : "/run/user/1000"
  }

  readonly property bool anyOn: isOn(noState) || isOn(enState)

  // The mic mirrors the most active of the two daemons: recording wins over
  // transcribing, which wins over plain idle.
  readonly property string micState: {
    const states = [noState, enState]
    if (states.indexOf("recording") >= 0 || states.indexOf("streaming") >= 0) return "recording"
    if (states.indexOf("transcribing") >= 0) return "transcribing"
    return anyOn ? "idle" : "stopped"
  }

  readonly property string statusLine: "Norsk: " + (isOn(noState) ? "på" + (noState !== "idle" ? " (" + noState + ")" : "") : "av")
      + " · Engelsk: " + (isOn(enState) ? "på" + (enState !== "idle" ? " (" + enState + ")" : "") : "av")

  function stateColor(s) {
    if (s === "recording" || s === "streaming") return "#f2594d"
    if (s === "transcribing") return "#f2cc4d"
    return null
  }

  function isOn(s) {
    return s === "idle" || s === "recording" || s === "streaming" || s === "transcribing"
  }

  active: anyOn
  activeText: "󰍬"
  inactiveText: "󰍭"
  activeTooltipText: statusLine + " — klikk slår av alt"
  inactiveTooltipText: statusLine + " — klikk slår på engelsk"
  useActiveColor: stateColor(micState) !== null
  activeColor: stateColor(micState) ?? "transparent"

  onPressed: function() {
    root.bar.run(root.anyOn ? "voxtype-daemon-all off" : "voxtype-daemon-toggle-en")
  }

  FileView {
    path: root.runDir + "/voxtype/state"
    watchChanges: true
    printErrors: false
    onLoaded: root.noState = (text() || "stopped").trim()
    onLoadFailed: root.noState = "stopped"
    onFileChanged: reload()
  }

  FileView {
    // NB: voxtype appends "/voxtype" to the runtime dir, so the English
    // daemon's state file is one level deeper than the Norwegian one.
    path: root.runDir + "/voxtype-en/voxtype/state"
    watchChanges: true
    printErrors: false
    onLoaded: root.enState = (text() || "stopped").trim()
    onLoadFailed: root.enState = "stopped"
    onFileChanged: reload()
  }
}
