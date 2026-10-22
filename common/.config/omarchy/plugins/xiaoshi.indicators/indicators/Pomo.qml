import QtQuick
import qs.Commons
import qs.Ui

// Pomodoro timer. Before it starts, only its icon, hidden until the
// indicators are hovered. Once started it shows only the phase, round and
// time: white while counting down, gray while paused.
//
// Left click starts or pauses, right click resets the phase, and middle click
// skips to the next one.
BarIndicator {
  id: root

  readonly property bool horizontalText: PomoState.started && !root.vertical

  active: PomoState.started
  activeText: root.vertical ? PomoState.icon : ""
  inactiveText: PomoState.icon
  labelText: root.horizontalText ? PomoState.label : ""
  activeTooltipText: PomoState.tooltip
  inactiveTooltipText: PomoState.tooltip

  // A paused timer is dimmed through its color, since an active indicator is
  // always drawn at full opacity.
  foreground: {
    var base = root.bar ? root.bar.barForeground : Color.foreground
    return PomoState.running || !PomoState.started ? base : Qt.alpha(base, 0.45)
  }

  // The label is wider than the icon slot the other indicators share. The
  // indicator is sized to the label alone, but BarIconButton still lays out an
  // empty glyph canvas after it and centers the pair, so the item is moved
  // back over by half of what the canvas takes to center the label itself.
  readonly property real canvasShare: root.canvasSize + Style.space(4)

  fixedWidth: root.horizontalText
    ? labelMetrics.advanceWidth + Style.space(8)
    : (root.vertical ? -1 : Style.bar.statusSlot)

  transform: Translate { x: root.horizontalText ? root.canvasShare / 2 : 0 }

  TextMetrics {
    id: labelMetrics
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    text: root.labelText
  }

  onPressed: function(b) {
    if (b === Qt.RightButton) PomoState.reset()
    else if (b === Qt.MiddleButton) PomoState.advance(false)
    else PomoState.toggle()
  }
}
