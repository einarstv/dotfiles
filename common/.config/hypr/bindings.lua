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

-- Screensaver; dismissing it lands on the login screen (screensaver-lock-watcher).
o.bind("SUPER + SHIFT + ESCAPE", "Screensaver", "omarchy-launch-screensaver")

-- Standard agent on SUPER + A (replaces Select all; Ctrl+A still works).
o.rebind("SUPER + A", "Agent", "omarchy-agent") -- was: Select all

-- Dictation by language: AltGr = English (whisper small.en), Right Ctrl = Norwegian
-- (nb-whisper-small). Voxtype constrains language detection to en/no, so the English
-- key picks 'en' and the Norwegian key picks 'no' per recording.
-- NB: on the "no" layout the physical AltGr key surfaces as ISO_Level3_Shift, not
-- Alt_R, so the binding (and the default Omarchy one) must use that keysym.
hl.unbind("ALT + Alt_R") -- remove the default dictation hold (dead on this layout: keysym never fires)
hl.unbind("SUPER + CTRL + X") -- was: Toggle dictation
hl.unbind("F9") -- was: push-to-talk dictation
o.bind_hold("ISO_Level3_Shift", "Dictate in English (push-to-talk)", "voxtype record start --model small.en", "Stop English dictation (push-to-talk)", "voxtype record stop", { ignore_mods = true })
o.bind_hold("CTRL + Control_R", "Dictate in Norwegian (push-to-talk)", "voxtype record start", "Stop Norwegian dictation (push-to-talk)", "voxtype record stop", { ignore_mods = true })
