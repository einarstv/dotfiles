# dotfiles

Omarchy (Hyprland) configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package that mirrors `$HOME`.

| Package    | Contents |
|------------|----------|
| `common/`  | Shared config, used on every machine: `~/.config/hypr/*` (except `monitors.lua`) and `~/.config/omarchy/{backgrounds,branding,defaults,extensions,hooks,plugins,themes,themed}` |
| `<host>/`  | Machine-specific files, one package per hostname. Currently `luwei/` with `monitors.lua` |

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

## Adding a file

Move it into the matching package with the same path relative to `$HOME`, then re-run stow:

```sh
mv ~/.config/foo/bar.conf ~/dotfiles/common/.config/foo/bar.conf   # mkdir -p the target dir first
cd ~/dotfiles && stow --no-folding common "$(hostname)"
```

## Not tracked

- `~/.config/omarchy/shell.toml` and `shell.json` (`shell.toml` is mode 600 and may hold secrets)
- `~/.config/omarchy/defaults/dictation.lock` (runtime marker)
- `~/.config/hypr/bindings.lua.bak.*` (backups)
- Installed packages and system-level settings (`/etc`, pacman packages)
