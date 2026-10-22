pragma Singleton

import QtQuick
import Quickshell
import qs.Commons

// The Pomodoro timer's one shared state. The Indicators widget builds each
// indicator more than once (active and inactive blocks, per orientation), so
// the countdown lives here rather than in the Pomo indicator itself.
Item {
  id: root

  // Seconds per phase: focus, short break, long break.
  readonly property var durations: [25 * 60, 5 * 60, 15 * 60]
  readonly property var phaseKeys: ["pomo.focus", "pomo.shortBreak", "pomo.longBreak"]
  readonly property var labelKeys: ["pomo.labelFocus", "pomo.labelBreak", "pomo.labelLongBreak"]

  property int phase: 0
  property int remaining: durations[0]
  property bool running: false
  // Started once the countdown has begun, and until it is reset or the phase
  // ends, so a paused timer still counts as started.
  property bool started: false
  property int completed: 0
  property double endsAt: 0

  Translations { id: strings; directory: Qt.resolvedUrl("../i18n") }

  // The round out of four: the one being focused on, or during a break the
  // one just finished.
  readonly property int round: phase === 0 ? completed % 4 + 1 : (phase === 2 ? 4 : completed % 4)
  readonly property string roundText: I18n.formatNumber(round) + "/" + I18n.formatNumber(4)
  readonly property string clock: pad(Math.floor(remaining / 60)) + ":" + pad(remaining % 60)
  readonly property string icon: phase === 0 ? "󰔛" : "󰅶"
  readonly property string label: strings.t(labelKeys[phase]) + " " + roundText + " " + clock
  readonly property string tooltip: strings.t(phaseKeys[phase]) + " " + roundText + " " + clock + "\n" + strings.t("pomo.hint")

  function pad(n) {
    var digits = I18n.formatNumber(n)
    return n < 10 ? I18n.formatNumber(0) + digits : digits
  }

  function toggle() {
    if (running) {
      running = false
    } else {
      // A wall-clock deadline keeps the countdown right across suspend and
      // a busy shell, which a counter of timer ticks would not.
      endsAt = Date.now() + remaining * 1000
      running = true
      started = true
    }
  }

  function reset() {
    running = false
    started = false
    remaining = durations[phase]
  }

  // Skipping leaves the session uncounted, so only a finished focus adds a dot.
  function advance(finished) {
    var previous = phase
    if (previous === 0 && finished) completed++
    phase = previous === 0 ? (finished && completed % 4 === 0 ? 2 : 1) : 0
    running = false
    started = false
    remaining = durations[phase]
    if (finished)
      notify(phase === 0 ? "pomo.notifyFocus" : phase === 2 ? "pomo.notifyLongBreak" : "pomo.notifyBreak")
  }

  function notify(key) {
    Quickshell.execDetached(["notify-send", "-a", "Pomo", strings.t(key)])
  }

  function tick() {
    remaining = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000))
    if (remaining === 0) advance(true)
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.running
    onTriggered: root.tick()
  }

  ShellIpc {
    target: "xiaoshi.pomo"

    function toggle(): void { root.toggle() }
    function reset(): void { root.reset() }
    function skip(): void { root.advance(false) }
  }
}
