-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Quake console (Super+S): drop the panel below the bar with a margin and
-- give it a border, instead of the flush, borderless default.
--
-- Omarchy's default.hypr.qconsole sizes the scratchpad panel with workspace
-- gaps and rewrites that rule on monitor and window events. This shadows the
-- same events — registered later, so it lands after qconsole's rewrite — and
-- re-applies the same geometry with a top margin and without qconsole's
-- no_border, so the console gets the thin accent border other windows have.
local QC_MARGIN = 10 -- px of air between the panel and the bar above
local QC_SHARE = 0.65 -- share of the usable screen height the console covers
local QC_BOX = 1.8 -- single-window panel is at most this many times wider than tall

local function qc_alone()
  local tiled = 0
  for _, window in ipairs(hl.get_workspace_windows("special:scratchpad")) do
    if not window.floating then
      tiled = tiled + 1
    end
  end
  return tiled <= 1
end

local function qc_monitor()
  local ws = hl.get_workspace("special:scratchpad")
  local mon = ws and ws.visible and ws.monitor
  if mon and mon.scale and mon.scale > 0 then
    return mon
  end
  return hl.get_active_monitor()
end

local function qc_apply(monitor)
  local mon = monitor or qc_monitor()
  if not mon or not mon.scale or mon.scale <= 0 then
    return
  end

  -- Same measurement as qconsole: physical to logical, reserved area off,
  -- quarter turns swap the work area.
  local width, height = mon.width, mon.height
  if mon.transform % 2 == 1 then
    width, height = height, width
  end
  local reserved = mon.reserved
  height = height / mon.scale - reserved.top - reserved.bottom
  width = width / mon.scale - reserved.left - reserved.right

  local tall = math.floor(height * QC_SHARE)
  local wide = width
  if qc_alone() then
    wide = math.min(width, tall * QC_BOX)
  end
  local side = math.floor((width - wide) / 2)
  local bottom = math.floor(height - tall - QC_MARGIN)

  hl.workspace_rule({
    workspace = "special:scratchpad",
    gaps_in = 0,
    gaps_out = { top = QC_MARGIN, right = side, bottom = bottom, left = side },
    -- The rule replace merges with qconsole's, which set no_border, so it
    -- has to be turned back off explicitly.
    no_border = false,
  })
  -- Land the new gaps in this pass rather than a frame later, so an open
  -- console does not visibly resize after it has dropped down.
  hl.exec_scheduled_prop_refresh_immediately()
end

qc_apply()

-- Seed the console the first time it opens. on_created_empty in a workspace
-- rule is deprecated since Hyprland 0.57; the replacement is a workspace.created
-- handler that checks the new workspace's .is_empty field.
hl.on("workspace.created", function(ws)
  if ws and ws.name == "special:scratchpad" and ws.is_empty then
    hl.dispatch(hl.dsp.exec_cmd("[workspace special:scratchpad silent] omarchy-agent"))
  end
end)

hl.on("monitor.layout_changed", function() qc_apply() end)
hl.on("monitor.focused", function() qc_apply() end)
hl.on("workspace.special_active", function(ws, mon)
  if ws and ws.name == "special:scratchpad" then
    qc_apply(mon)
  end
end)
hl.on("workspace.move_to_monitor", function(ws, mon)
  if ws and ws.name == "special:scratchpad" then
    qc_apply(mon)
  end
end)
local function qc_recount()
  local ws = hl.get_workspace("special:scratchpad")
  if ws and ws.visible then
    qc_apply()
  end
end
hl.on("window.open", qc_recount)
hl.on("window.destroy", qc_recount)
hl.on("window.move_to_workspace", qc_recount)
hl.on("window.update_rules", qc_recount)
