import QtQuick

// mini-orb: compact circular OSD for voxtype's Quickshell frontend.
// Size follows osd.height_px from config.toml (clamped 56..240).
// States: recording = pulsing ring + voice bars,
//         transcribing = amber spinner + glyph,
//         streaming = blue glyph. The host hides the surface at idle.

Item {
    id: root

    // Injected by OsdSurface (see _syncCustomItem there).
    property string daemonState: "idle"
    property var audio: null
    property var theme: null
    property var recipe: null
    property string assetRoot: ""

    // Audio levels, updated from the bridge's frame signal.
    property real framePeak: 0.0
    property real frameRms: 0.0

    function _configValue(key, fallback) {
        return theme && theme.config && theme.config[key] !== undefined
            ? theme.config[key]
            : fallback;
    }

    function _color(role, fallback) {
        if (theme && theme.color) return theme.color(role, fallback);
        return fallback;
    }

    function _clamp(value, lo, hi) {
        return Math.max(lo, Math.min(hi, value));
    }

    readonly property int size: _clamp(Math.round(Number(_configValue("height_px", 96)) || 96), 56, 240)

    readonly property color stateColor: {
        if (daemonState === "recording") return _color("recording", "#F2594D");
        if (daemonState === "streaming") return _color("streaming", "#66C7FF");
        if (daemonState === "transcribing") return _color("transcribing", "#F2CC4D");
        return _color("idle", "rgba(235, 235, 242, 0.75)");
    }

    anchors.fill: parent

    function _orbX(size) {
        const position = String(_configValue("position", "bottom-center"));
        const margin = Math.max(0, Number(_configValue("margin_px", 24)));
        if (position.indexOf("left") >= 0) return margin;
        if (position.indexOf("right") >= 0) return Math.max(margin, width - size - margin);
        return Math.max(margin, (width - size) / 2);
    }

    function _orbY(size) {
        const position = String(_configValue("position", "bottom-center"));
        const margin = Math.max(0, Number(_configValue("margin_px", 24)));
        if (position === "top-left" || position === "top-right") return margin;
        if (position === "bottom-left" || position === "bottom-right") {
            return Math.max(margin, height - size - margin);
        }
        const topMargin = _clamp(Number(_configValue("top_margin", 0.85)), 0.0, 1.0);
        return Math.max(margin, Math.min(height - size - margin, height * topMargin));
    }

    Connections {
        target: root.audio
        enabled: root.audio !== null

        function onFrameReceived(framePeak, frameRms, vad, tsMs) {
            root.framePeak = root._clamp(framePeak, 0.0, 1.0);
            root.frameRms = root._clamp(frameRms, 0.0, 1.0);
        }
    }

    Rectangle {
        id: orb

        x: root._orbX(root.size)
        y: root._orbY(root.size)
        width: root.size
        height: root.size
        radius: width / 2
        color: root._color("background", "rgba(26, 26, 31, 0.85)")
        border.width: root.daemonState === "recording"
            ? 2 + root.framePeak * 5
            : 2
        border.color: root.stateColor
        opacity: 0.96

        Behavior on border.width { NumberAnimation { duration: 90 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }

        // Voice bars while recording/streaming.
        Row {
            id: bars

            anchors.centerIn: parent
            spacing: Math.max(3, root.size * 0.05)
            visible: root.daemonState === "recording" || root.daemonState === "streaming"

            Repeater {
                model: 3

                Rectangle {
                    required property int index

                    // Aggressive gain so normal speech sweeps the bars instead
                    // of barely moving them: rms dominates, peak adds punch.
                    readonly property real energy: Math.min(1.0, root.frameRms * (9.0 + index * 4.0) + root.framePeak * 1.5)

                    width: Math.max(3, root.size * 0.06)
                    radius: width / 2
                    color: root.stateColor
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    height: Math.max(width, root.size * 0.30 * (0.30 + 0.70 * energy))

                    Behavior on height { NumberAnimation { duration: 70 } }
                }
            }
        }

        // Spinner while transcribing: empty center, only a dot riding the
        // outer ring, going round and round.
        Item {
            anchors.fill: parent
            visible: root.daemonState === "transcribing"

            RotationAnimation on rotation {
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 1400
                running: parent.visible
            }

            Rectangle {
                x: parent.width / 2 - width / 2
                y: orb.border.width / 2 - height / 2
                width: Math.max(5, root.size * 0.085)
                height: width
                radius: width / 2
                color: root.stateColor
                antialiasing: true
            }
        }

        // Glyph while streaming.
        Text {
            anchors.centerIn: parent
            visible: root.daemonState === "streaming"
            text: "\uF051F"
            color: root.stateColor
            font.pixelSize: Math.round(root.size * 0.30)
        }
    }
}
