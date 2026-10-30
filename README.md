# dotfiles

Omarchy (Hyprland) configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package that mirrors `$HOME`.

| Package    | Contents |
|------------|----------|
| `common/`  | Shared config, used on every machine: `~/.config/hypr/*` (except `monitors.lua`), `~/.config/kitty/kitty.conf`, `~/.config/omarchy/{backgrounds,branding,defaults,extensions,hooks,plugins,themes,themed}`, `~/.local/bin/` helper scripts (lid, voxtype, workspace layout, reminders) |
| `<host>/`  | Machine-specific files, one package per hostname. Currently `lisan/` and `luwei/` with `monitors.lua` and `shell.json` (lisan also has `.local/bin/dock-hub-nosuspend-setup`) |

Rule of thumb: each setting lives in exactly one place. Shared settings go in `common/`; a host package holds only what genuinely differs.

## Usage

Stow the shared package plus the one for this machine:

```sh
cd ~/dotfiles
stow --no-folding common "$(hostname)"
```

`--no-folding` makes Stow link individual files rather than whole directories, so files created by apps in `~/.config` don't end up inside the repo.

To remove the links: `stow -D --no-folding common "$(hostname)"`.

## Adding a machine

1. Clone the repo to `~/dotfiles`.
2. Create `<hostname>/.config/hypr/monitors.lua` with that machine's monitor setup.
3. Move any existing `~/.config/hypr/*.lua` files that Stow would replace out of the way (Stow reports conflicts rather than overwriting).
4. Run the stow command above and reload Hyprland (`hyprctl reload`).
5. On a laptop, run `~/.local/bin/lid-screen-off-setup` (asks for sudo) so closing the lid turns the screen off instead of suspending.
6. On lisan (or any machine using the dock), run `~/.local/bin/dock-hub-nosuspend-setup` (asks for sudo) — when the dock's GenesysLogic USB2 hub autosuspends, its RTL8153 ethernet NIC stalls and drops off the bus, killing all connectivity until it re-enumerates.
7. Fetch the voxtype dictation models (per-machine downloads, not tracked): `rsync <existing-host>:.local/share/voxtype/models/ ~/.local/share/voxtype/models/` — the daemons need `nb-whisper-small.bin` (Norwegian, F10) and `ggml-small.en.bin` (English, F9). Without them `voxtype.service` crash-loops at login. `voxtype setup` can download them instead.

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
