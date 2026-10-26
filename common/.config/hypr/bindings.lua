-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Focus movement: SUPER + H/J/K/L mirrors SUPER + Arrow keys.
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" })) -- was: Toggle window split
o.rebind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" })) -- was: Keybindings menu
o.rebind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" })) -- was: Cycle workspace layout

-- Window swap: SUPER + SHIFT + H/J/K/L mirrors SUPER + SHIFT + Arrows.
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" })) -- was: Cycle workspace layout

-- Toggle window split on SUPER + X (replaces Universal cut; was briefly on SUPER + ALT + J).
o.rebind("SUPER + X", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Cycle workspace layout on SUPER + ALT + L (replaces "Cycle workspace layout back"; was on SUPER + SHIFT + L).
o.rebind("SUPER + ALT + L", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- The dock is disabled, so SUPER + M (was: Minimize window to the dock) would
-- strand windows on the hidden special:minimized workspace with no way back.
hl.unbind("SUPER + M")

-- SUPER + T opens the terminal (same action as SUPER + ENTER); the floating
-- toggle that lived on SUPER + T moves to SUPER + SHIFT + T.
o.rebind("SUPER + T", "Terminal", o.launch_terminal()) -- was: Toggle window floating/tiling
o.bind("SUPER + SHIFT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Laptop lid: keep Omarchy's clamshell display handling (internal screen off on
-- close, restored on open) but skip the session lock, so opening the lid goes
-- straight back to the desktop. Suspend on lid close is disabled separately in
-- /etc/systemd/logind.conf.d/30-lid-screen-off.conf.
o.rebind("switch:on:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })

-- Screensaver; dismissing it lands on the login screen (screensaver-lock-watcher).
-- Absolute path: the compositor's PATH prefers /usr/bin over ~/.local/bin, and
-- this wrapper forces the screensaver into Alacritty while kitty stays default.
o.rebind("SUPER + SHIFT + ESCAPE", "Screensaver", "/home/xiaoshi/.local/bin/omarchy-launch-screensaver")

-- Standard agent on SUPER + A (replaces Select all; Ctrl+A still works).
o.rebind("SUPER + A", "Agent", "omarchy-agent") -- was: Select all

-- Move window to scratchpad on SUPER + SHIFT + S (same action as SUPER + ALT + S).
hl.unbind("SUPER + SHIFT + S") -- was: Google Maps
o.bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- YouTube webapp on SUPER + Y (plain SUPER + Y was unbound; moved from SUPER + SHIFT + Y).
hl.unbind("SUPER + SHIFT + Y") -- was: YouTube
o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/" })

-- Dictation by language, one daemon per language:
--   F9  = English PTT   (voxtype-english.service, language = "en",  small.en)
--   F10 = Norwegian PTT (voxtype.service,         language = "no",  nb-whisper-small)
-- Shift + the same keys toggle each daemon. Plain F-keys bind cleanly with
-- exact masks; modifier keys (Right Ctrl, AltGr) trigger a spurious instant
-- release in Hyprland that killed recordings at 0.0s.
hl.unbind("ALT + Alt_R") -- remove the default dictation hold (dead on this layout: keysym never fires)
hl.unbind("SUPER + CTRL + X") -- was: Toggle dictation
hl.unbind("F9") -- was: default push-to-talk dictation (ours is bound below)

o.bind_hold("F9", "Dictate in English (push-to-talk)", "voxtype-dictation-en start", "Stop English dictation (push-to-talk)", "voxtype-dictation-en stop")
o.bind_hold("F10", "Dictate in Norwegian (push-to-talk)", "voxtype record start", "Stop Norwegian dictation (push-to-talk)", "voxtype record stop")
o.bind("SHIFT + F9", "Toggle English dictation daemon", "voxtype-daemon-toggle-en")
o.bind("SHIFT + F10", "Toggle Norwegian dictation daemon", "voxtype-daemon-toggle-no")
