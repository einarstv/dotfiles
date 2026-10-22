import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

// Dictation mic for the two voxtype daemons:
//   N = Norwegian (voxtype.service)        E = English (voxtype-english.service)
// Hidden while both daemons are off. When either is on the mic shows: lit
// normal at idle, red = recording, amber = transcribing. Click activates
// English when both are off, otherwise turns all daemons off. Hover shows
// the state of both.

BarWidget {
  id: root
  moduleName: "xiaoshi.voxtype"

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

  implicitWidth: root.anyOn ? button.implicitWidth : 0
  implicitHeight: root.anyOn ? button.implicitHeight : 0
  visible: root.anyOn

  BarIconButton {
    id: button

    bar: root.bar
    anchors.centerIn: parent
    fixedWidth: -1
    text: "󰍬"
    active: root.stateColor(root.micState) !== null
    activeColor: root.stateColor(root.micState) ?? "transparent"
    tooltipText: root.statusLine
        + (root.anyOn ? " — klikk slår av alt" : " — klikk slår på engelsk")
    onPressed: function(b) {
      if (b !== Qt.LeftButton) return
      root.bar.run(root.anyOn ? "voxtype-daemon-all off" : "voxtype-daemon-toggle-en")
    }
  }
}
