import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

// Dictation mic for the two voxtype daemons:
//   English   = voxtype-english.service  (hold AltGr)
//   Norwegian = voxtype.service          (hold Right Ctrl)
// Always visible in the tray: muted glyph, dim while both daemons are off;
// lit when either is on, red = recording, amber = transcribing. Hover shows
// the state of both. Click activates English when both are off, otherwise
// turns all daemons off. Right click toggles the Norwegian daemon.

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
    if (s === "transcribing") return "writing"
    if (s === "idle") return "ready"
    return "off"
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

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button

    bar: root.bar
    anchors.centerIn: parent
    text: root.anyOn ? "󰍬" : "󰍭"
    active: root.stateColor(root.micState) !== null
    activeColor: root.stateColor(root.micState) ?? "transparent"
    dimmed: !root.anyOn
    tooltipText: "English: " + root.stateLabel(root.enState)
        + " · Norwegian: " + root.stateLabel(root.noState)
        + "\nClick: all off / start English · Right: Norwegian on/off"
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        root.bar.run("voxtype-daemon-toggle-no")
      } else if (b === Qt.LeftButton) {
        root.bar.run(root.anyOn ? "voxtype-daemon-all off" : "voxtype-daemon-toggle-en")
      }
    }
  }
}
