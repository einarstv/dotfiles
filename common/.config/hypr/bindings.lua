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

-- Swap split halves on SUPER + X (replaces Universal cut; was briefly on SUPER + ALT + J).
o.rebind("SUPER + X", "Swap split halves", hl.dsp.layout("swapsplit"))

-- Toggle window split on SUPER + SHIFT + X (was on SUPER + X; replaces the X webapp).
o.rebind("SUPER + SHIFT + X", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Group tab navigation on SUPER + TAB / SUPER + SHIFT + TAB (was: Next/Previous
-- workspace, still available on SUPER + mouse scroll; SUPER + ALT + TAB variants
-- keep working as aliases).
o.rebind("SUPER + TAB", "Next window in group", hl.dsp.group.next())
o.rebind("SUPER + SHIFT + TAB", "Previous window in group", hl.dsp.group.prev())

-- Move window into a group in that direction on SUPER + CTRL + SHIFT + H/J/K/L
-- (mirrors SUPER + SHIFT + H/J/K/L window swaps; the SUPER + ALT + arrow
-- defaults for the same action stay as aliases).
o.bind("SUPER + CTRL + SHIFT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + CTRL + SHIFT + J", "Move window to group below", hl.dsp.window.move({ into_group = "d" }))
o.bind("SUPER + CTRL + SHIFT + K", "Move window to group above", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + CTRL + SHIFT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

-- Pull the focused window out of its group on SUPER + SHIFT + G (replaces the
-- Signal launcher; SUPER + ALT + G default stays as an alias).
o.rebind("SUPER + SHIFT + G", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))

-- Cycle workspace layout on SUPER + ALT + L (replaces "Cycle workspace layout back"; was on SUPER + SHIFT + L).
-- The wrapper extends Omarchy's dwindle -> scrolling -> floating cycle with a
-- centered master step (the bar's layout click uses the same wrapper).
o.rebind("SUPER + ALT + L", "Cycle workspace layout", "omarchy-workspace-layout-toggle-plus")

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

-- Screensaver (stock native launcher). Idle locking is the shell's job:
-- idle.lock in ~/.config/omarchy/shell.json locks 30s after the screensaver
-- starts. A manual launch here plays the screensaver without locking on exit.
o.rebind("SUPER + SHIFT + ESCAPE", "Screensaver", "omarchy-launch-screensaver")

-- Standard agent on SUPER + A (replaces Select all; Ctrl+A still works).
o.rebind("SUPER + A", "Agent", "omarchy-agent") -- was: Select all

-- Move window to scratchpad on SUPER + SHIFT + S (same action as SUPER + ALT + S).
hl.unbind("SUPER + SHIFT + S") -- was: Google Maps
o.bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Claude Code in the scratchpad console on SUPER + CTRL + S (replaces Share;
-- the share menu stays in the root menu). SUPER + S keeps opening the default
-- agent (OpenCode) through the console's seeding in hyprland.lua; this key
-- asks the seeding for Claude when it opens the uncreated console, starts
-- Claude directly when the console already exists (the seeding only fires on
-- creation, so it can never double-spawn), and toggles Claude's console once
-- Claude is running. Claude's window has its own org.omarchy.claude class
-- (every agent omarchy-agent launches shares org.omarchy.agent), which is what
-- the focus below matches on.
o.rebind("SUPER + CTRL + S", "Claude Code (scratchpad)", function()
  local claude = nil
  for _, window in ipairs(hl.get_workspace_windows("special:scratchpad")) do
    if window.class == "org.omarchy.claude" then
      claude = window
      break
    end
  end

  local ws = hl.get_workspace("special:scratchpad")
  local visible = ws and ws.visible

  if claude then
    -- Toggle Claude's console: close when open, show and focus when hidden.
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
    if not visible then
      hl.dispatch(hl.dsp.focus({ window = "address:" .. claude.address }))
    end
  elseif ws then
    -- The console exists, holding other windows (e.g. OpenCode from SUPER + S)
    -- or empty: open it when hidden and start Claude directly.
    if not visible then
      hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
    end
    hl.exec_cmd(
      "omarchy-launch-tui --app-id=org.omarchy.claude omarchy-agent --inline --agent claude",
      { workspace = "special:scratchpad silent" }
    )
  else
    -- No console yet: open it and let the seeding start Claude (the flag
    -- switches it from the default agent for this one opening).
    scratchpad_seed_agent = "claude"
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end
end)

-- YouTube webapp on SUPER + Y (plain SUPER + Y was unbound; moved from SUPER + SHIFT + Y).
hl.unbind("SUPER + SHIFT + Y") -- was: YouTube
o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/" })

-- Dictation: one daemon, one mode-aware key, one pinned language.
-- ALT + SPACE records while held (default) or toggles on tap, per the mode
-- file flipped by the bar mic icon's right click (voxtype-chord /
-- voxtype-mode-toggle); the icon's click always toggles recording. The
-- daemon's language is PINNED per variant in config-{no,en}.toml (no Swedish
-- misfires from auto-detect) and switched Norwegian <-> English by
-- SHIFT + ALT + SPACE (voxtype-lang), which copies the variant over the
-- active config.toml and restarts voxtype.service (~0.4s). voxtype.service
-- starts with the session.
-- voxtype-chord itself reads the mode file, so o.bind_hold's press/release
-- halves are all it takes; the same installed-backend guard as Omarchy's
-- own dictation keys.
hl.unbind("ALT + Alt_R") -- remove the default dictation hold (dead on this layout: keysym never fires)
hl.unbind("SUPER + CTRL + X") -- was: Toggle dictation
hl.unbind("F9") -- was: default push-to-talk dictation
hl.unbind("ALT + SPACE") -- was: Toggle dictation (default tap-to-speak; rebound as the chord below)

if o.dictation_installed and o.dictation_installed() then
  o.bind_hold("ALT + SPACE", "Dictate (hold to speak, or tap in tap mode)", "voxtype-chord press", "Stop dictation (hold mode)", "voxtype-chord release")
end

-- Switch the daemon's pinned dictation language Norwegian <-> English
-- (voxtype-lang swaps whisper.language + prompt and restarts the daemon).
o.bind("SHIFT + ALT + SPACE", "Toggle dictation language (Norwegian/English)", "voxtype-lang")
