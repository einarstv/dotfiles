-- lisan-only overrides, loaded after the shared hypr/*.lua files.

-- Workspace switches: plain slide (common uses "slidefade 20%").
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "slide",
})
