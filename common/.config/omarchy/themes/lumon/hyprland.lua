-- Lumon theme override: keep the border colors, drop the blue glow.
-- Overlay on top of /usr/share/omarchy/themes/lumon/hyprland.lua
-- Border uses the theme accent (#8bc9eb) instead of bright near-white.
local active_border_color = "rgb(8bc9eb)"
local inactive_border_color = "rgba(30486099)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    }
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = false,
    },
  },
})
