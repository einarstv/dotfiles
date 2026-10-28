# dotfiles

Omarchy (Hyprland) configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package that mirrors `$HOME`.

| Package    | Contents |
|------------|----------|
| `common/`  | Shared config, used on every machine: `~/.config/hypr/*` (except `monitors.lua`), `~/.config/kitty/kitty.conf`, `~/.config/omarchy/{backgrounds,branding,defaults,extensions,hooks,plugins,themes,themed}`, `~/.local/bin/` helper scripts (lid, screensaver, voxtype, workspace layout) and `~/.config/alacritty-screensaver-xdg-terminals.list` |
| `<host>/`  | Machine-specific files, one package per hostname. Currently `lisan/` and `luwei/` with `monitors.lua` and `shell.json` |

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
6. Install alacritty (`omarchy pkg add alacritty`) — the screensaver wrapper forces the screensaver into Alacritty while kitty stays the default.

If Stow reports conflicts for files it once linked (apps rewrote them into real files since), move those files aside and re-run stow rather than using `--adopt` blindly.

## Screensaver and lock

Two scripts in `common/.local/bin/` work as a pair; Stow links both onto PATH:

- `omarchy-launch-screensaver` (bound to `SUPER+SHIFT+ESCAPE`) scopes `XDG_CURRENT_DESKTOP` so `xdg-terminal-exec` resolves the screensaver to Alacritty via `~/.config/alacritty-screensaver-xdg-terminals.list`, then parks the desktop on workspace 6 with the bar hidden before the screensaver opens. Workspace 6 is kept empty by convention — don't use it for windows.
- `screensaver-lock-watcher` (started by `~/.config/hypr/autostart.lua`) watches Hyprland's event stream; when the last `org.omarchy.screensaver` window closes it locks the session and undoes the staging underneath the lock. Dismissing the screensaver therefore lands on the login screen, and unlocking reveals the desktop exactly as it was left.

Both honor the stay-awake switch (`SUPER+CTRL+I`): while it is on, no staging happens and nothing locks. Diagnostics land in `~/.local/state/omarchy/screensaver-flash.log`.

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
- Installed packages and most system-level settings (`/etc`, pacman packages). Exception: laptop lid handling is installed by `common/.local/bin/lid-screen-off-setup`
