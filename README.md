# dotfiles

Omarchy (Hyprland) configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package that mirrors `$HOME`.

| Package    | Contents |
|------------|----------|
| `common/`  | Shared config, used on every machine: `~/.config/hypr/*` (except `monitors.lua`), `~/.config/kitty/kitty.conf`, `~/.config/omarchy/{backgrounds,branding,defaults,extensions,hooks,plugins,themed}`, `~/.local/bin/` helper scripts (lid, voxtype, workspace layout, reminders, theme sync) |
| `<host>/`  | Machine-specific files, one package per hostname. Currently `lisan/` and `luwei/` with `monitors.lua` and `shell.json` (lisan also has `.local/bin/dock-hub-nosuspend-setup` and `.config/omarchy/hooks/post-boot.d/blank-internal-monitor`) |

Rule of thumb: each setting lives in exactly one place. Shared settings go in `common/`; a host package holds only what genuinely differs.

## Usage

Stow the shared package plus the one for this machine:

```sh
cd ~/dotfiles
stow --no-folding common "$(hostname)"
```

`--no-folding` makes Stow link individual files rather than whole directories, so files created by apps in `~/.config` don't end up inside the repo.

To remove the links: `stow -D --no-folding common "$(hostname)"`.

## Theme overlays: no Stow links

`omarchy theme set` copies `~/.config/omarchy/themes/<name>/` into
`~/.local/state/omarchy/current/theme/` — a different directory depth. A
Stow link's relative target dangles there, and one dangling link aborts
Omarchy's template rendering mid-run (`awk: fatal: cannot redirect`),
silently skipping every generated config after it alphabetically —
`kitty.conf` included, leaving the terminal on stock colors (seen
2026-10-30, via a stowed `lumon/hyprland.lua`). Keep theme overlays to
real files or absolute symlinks; version their content elsewhere in the
repo and copy it in.

## shell.json: synced at commit time, not Stow-linked

Omarchy rewrites `~/.config/omarchy/shell.json` on every bar, plugin, or
idle change (`atomicWrites: true` — temp file, then `rename()`), and
`rename()` replaces a symlink instead of following it. A Stow link on the
file survives only until the first such write, which silently swaps it for
a plain file and leaves the repo copy stale (seen 2026-11-02: the `glassy`
bar background and `xiaoshi.lock` enable existed only in the live file).

So `<host>/.config/omarchy/shell.json` is a synced record, not a link:
`.githooks/pre-commit` compares the repo copy against the live file
(semantically — Omarchy re-serializes key order, so byte drift alone is
re-recorded without comment) and **stops the commit on real drift**,
printing the diff. Record the current live config explicitly:

```sh
~/dotfiles/.githooks/pre-commit --sync
```

Activate the hook per machine, and keep the stow-side guard that stops a
re-stow from ever linking the file (each host package needs the ignore;
see `lisan/.stow-local-ignore`):

```sh
git config core.hooksPath .githooks
```

## Adding a machine

1. Clone the repo to `~/dotfiles`.
2. Create `<hostname>/.config/hypr/monitors.lua` with that machine's monitor setup.
3. Move any existing `~/.config/hypr/*.lua` files that Stow would replace out of the way (Stow reports conflicts rather than overwriting).
4. Run the stow command above and reload Hyprland (`hyprctl reload`).
5. Run `git config core.hooksPath .githooks` so commits sync the live `shell.json` into this host's package (see above).
6. On a laptop, run `~/.local/bin/lid-screen-off-setup` (asks for sudo) so closing the lid turns the screen off instead of suspending.
7. On lisan (or any machine using the dock), run `~/.local/bin/dock-hub-nosuspend-setup` (asks for sudo) — when the dock's GenesysLogic USB2 hub autosuspends, its RTL8153 ethernet NIC stalls and drops off the bus, killing all connectivity until it re-enumerates.
8. VoxType dictation is remote-only via Groq: create `~/.config/voxtype/groq.env` with `VOXTYPE_WHISPER_API_KEY=<key>` (per-machine secret, not tracked). No local models needed. Language is pinned per variant in `common/.config/voxtype/config-{no,en}.toml`; `voxtype-lang` copies the chosen variant over `~/.config/voxtype/config.toml` (generated, not tracked) and restarts the daemon.

If Stow reports conflicts for files it once linked (apps rewrote them into real files since), move those files aside and re-run stow rather than using `--adopt` blindly.

## Screensaver and lock

Stock Omarchy behavior, no local scripts: the shell's idle service starts the
native screensaver (`idle.screensaver`, 600s) and locks the session itself
(`idle.lock`, 630s — 30s after the screensaver appears) — both set per host in
`<host>/.config/omarchy/shell.json`. Returning within those 30s dismisses the
screensaver without a lock. The stay-awake switch (`SUPER+CTRL+I`) suspends
both timers. `SUPER+SHIFT+ESCAPE` launches the screensaver on demand; a manual
launch does not lock on exit.

An earlier design staged an empty workspace and locked from a
`screensaver-lock-watcher` when the screensaver's terminal window closed. It
died with the omarchy-screensaver 1.3.1 update (Oct 2026): the screensaver is
now a native layer-shell overlay, which is not a Hyprland window, so it
produces no window events to watch. Old diagnostics may remain in
`~/.local/state/omarchy/screensaver-flash.log`.

## Docked laptop: blank the internal panel (lisan)

Booting with the dock monitor connected should leave the ThinkPad panel dark —
off entirely, not lit with a frozen boot logo. Two pieces:

- **"Laptop Display Off" toggle** (Omarchy Hardware menu): keeps eDP-1
  `disabled = true` through the state flag
  `~/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua`. Omarchy
  clears it automatically when booting without an external display, and the
  Hardware menu's "Laptop Display On" reverses it anytime. Runtime state, not
  tracked here.
- **`lisan/.config/omarchy/hooks/post-boot.d/blank-internal-monitor`**: a
  panel Hyprland never enables is never powered down — the driver runs its
  panel-off sequence (backlight, panel power) only when an *enabled* output is
  disabled. So after the desktop starts, the hook briefly enables eDP-1 and
  disables it again, which properly cuts power. Without it, the firmware's
  boot logo stays lit on the panel for the entire session.

The panel still shows the Lenovo logo from power-on until the desktop starts:
that part is drawn by the firmware, before Linux runs.

**TODO, not tried yet**: BIOS (F1 at boot) → **Config → Display → Boot Display
Device** → pick the Digital/Dock option. That should send boot output to the
dock monitor instead, so the panel never lights at all.

Dead end, don't re-test: `i915.enable_psr=0` on the kernel cmdline (drop-in
`/etc/limine-entry-tool.d/psr.conf` + `limine-mkinitcpio`) made no difference —
the ghost frame is the driver never taking ownership, not panel self-refresh.
Removed 2026-11-05. Caveat: the one verified-black reboot ran with the param
active; if a docked reboot ends on a frozen frame instead, PSR was load-bearing
for the disable path after all — re-add the drop-in and rebuild.

## Adding a file

Move it into the matching package with the same path relative to `$HOME`, then re-run stow:

```sh
mv ~/.config/foo/bar.conf ~/dotfiles/common/.config/foo/bar.conf   # mkdir -p the target dir first
cd ~/dotfiles && stow --no-folding common "$(hostname)"
```

## Not tracked

- `~/.config/omarchy/shell.toml` (mode 600, may hold secrets)
- `~/.config/omarchy/defaults/dictation.lock` (runtime marker)
- `~/.config/hypr/bindings.lua.bak.*` (backups)
- Installed packages and most system-level settings (`/etc`, pacman packages). Exceptions: laptop lid handling is installed by `common/.local/bin/lid-screen-off-setup`, and lisan's dock hub power rule by `lisan/.local/bin/dock-hub-nosuspend-setup`
