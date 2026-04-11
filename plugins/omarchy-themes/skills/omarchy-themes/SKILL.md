---
name: omarchy-themes
description: Use when creating, editing, or publishing an Omarchy theme. Trigger when the user wants to make a new theme, customize an existing one, add/change backgrounds, tweak colors.toml, enable light mode, pick icons, write a theme preview, or package a theme for distribution. Activate on work under ~/.config/omarchy/themes/ and when referencing omarchy-theme-set / omarchy-theme-install.
---

# Omarchy Themes

Omarchy themes are plain directories containing a color palette, wallpapers, and optional per-app overrides. One `colors.toml` drives the entire desktop — terminals, Waybar, Hyprland borders, btop, mako, walker, swayosd, chromium, and more — by populating templates at theme-set time.

Reference: https://learn.omacom.io/2/the-omarchy-manual/92/making-your-own-theme

## When to use this skill

- Creating a new theme in `~/.config/omarchy/themes/<name>/`
- Editing `colors.toml`, `backgrounds/`, `icons.theme`, `light.mode`, `neovim.lua`, `vscode.json`, `btop.theme`, or per-app overrides inside a theme directory
- Converting a palette (Base16, vim colorscheme, brand colors) into an Omarchy theme
- Packaging a theme into an `omarchy-<name>-theme` git repo for `omarchy-theme-install`
- Debugging why a theme looks wrong after `omarchy-theme-set`

For general Omarchy config (Hyprland, Waybar modules, keybindings, etc.) defer to the `omarchy` skill. This skill is strictly about the theme directory.

## Directory layout

```
~/.config/omarchy/themes/          # user themes (editable)
~/.local/share/omarchy/themes/     # stock themes (READ-ONLY reference, do NOT edit)
```

Copy a stock theme as a starting point:

```bash
cp -r ~/.local/share/omarchy/themes/tokyo-night ~/.config/omarchy/themes/my-theme
```

At `omarchy-theme-set <name>` time, Omarchy merges files with user-theme files taking precedence over the stock theme of the same name. A user-theme directory with the same name as a stock theme **overlays** it rather than replacing it — useful for tweaking one file without copying the whole theme.

## Theme slug vs display name

`omarchy-theme-set "Tokyo Night"` and `omarchy-theme-set tokyo-night` both work. Internally the name is lowercased and spaces become hyphens, so the on-disk directory MUST be the slug form (`tokyo-night`, `my-theme`), not the display form.

## Required file: colors.toml

The heart of a modern Omarchy theme. Minimal valid contents:

```toml
accent               = "#7aa2f7"
cursor               = "#c0caf5"
foreground           = "#a9b1d6"
background           = "#1a1b26"
selection_foreground = "#c0caf5"
selection_background = "#7aa2f7"

# 16-color terminal palette (ANSI 0–15)
color0  = "#32344a"  # black
color1  = "#f7768e"  # red
color2  = "#9ece6a"  # green
color3  = "#e0af68"  # yellow
color4  = "#7aa2f7"  # blue
color5  = "#ad8ee6"  # magenta
color6  = "#449dab"  # cyan
color7  = "#787c99"  # white
color8  = "#444b6a"  # bright black
color9  = "#ff7a93"  # bright red
color10 = "#b9f27c"  # bright green
color11 = "#ff9e64"  # bright yellow
color12 = "#7da6ff"  # bright blue
color13 = "#bb9af7"  # bright magenta
color14 = "#0db9d7"  # bright cyan
color15 = "#acb0d0"  # bright white
```

**Rules:**
- Hex colors must be quoted strings, `#RRGGBB` format (no `#RGB` shorthand, no alpha).
- All 22 keys above are expected — omitting any will leave template slots unfilled in the generated configs.
- `accent` drives Hyprland active border color and most highlight accents.
- `color0`–`color15` follow the standard ANSI terminal layout (0–7 normal, 8–15 bright).

### How colors.toml becomes app configs

If `colors.toml` exists, `omarchy-theme-set-templates` renders every `.tpl` file under `~/.local/share/omarchy/default/themed/` (plus any in `~/.config/omarchy/themed/`) into the active theme directory, substituting:

| Placeholder             | Example expansion               |
|-------------------------|---------------------------------|
| `{{ background }}`      | `#1a1b26`                       |
| `{{ background_strip }}`| `1a1b26` (no leading `#`)       |
| `{{ background_rgb }}`  | `26,27,38` (decimal R,G,B)      |
| `{{ color4 }}`          | `#7aa2f7`                       |
| `{{ color4_strip }}`    | `7aa2f7`                        |
| `{{ color4_rgb }}`      | `122,162,247`                   |
| `{{ accent }}` / `{{ accent_strip }}` / `{{ accent_rgb }}` | (accent color) |

Same pattern applies to every key in `colors.toml`. Use `_strip` for places that need a bare hex (Hyprland `rgb(...)`), `_rgb` for places that want decimal RGB triplets.

**Templates that are auto-generated from `colors.toml`** (as of current Omarchy):

```
alacritty.toml   btop.theme      chromium.theme   ghostty.conf
hyprland.conf    hyprlock.conf   keyboard.rgb     kitty.conf
mako.ini         obsidian.css    swayosd.css      walker.css
waybar.css       hyprland-preview-share-picker.css
```

**Override behavior:** if a file with the same name already exists inside the theme directory (e.g. you ship your own `waybar.css`), it is NOT overwritten by the template. This is the hook for per-theme customization beyond what the palette expresses.

To inspect current templates on this system:

```bash
ls ~/.local/share/omarchy/default/themed/
cat ~/.local/share/omarchy/default/themed/<name>.tpl
```

## Optional files

### `light.mode`

Empty marker file. Its presence flips the desktop into light mode (GNOME `prefer-light`, Adwaita GTK) when the theme is applied. Create it with `touch`:

```bash
touch ~/.config/omarchy/themes/my-theme/light.mode
```

Dark themes should NOT have this file.

### `icons.theme`

Single-line file containing a GTK icon theme name. Valid Yaru variants shipped with Omarchy:

```
Yaru              Yaru-blue         Yaru-dark         Yaru-magenta
Yaru-olive        Yaru-prussiangreen Yaru-purple      Yaru-red
Yaru-sage         Yaru-wartybrown   Yaru-yellow
```

Example:

```bash
echo "Yaru-magenta" > ~/.config/omarchy/themes/my-theme/icons.theme
```

### `backgrounds/`

Directory of wallpapers cycled by `omarchy-theme-bg-next`. Any common image format works (`.jpg`, `.png`, `.webp`). Number them (`0-foo.jpg`, `1-bar.png`) to control default order. At least one background is expected — `omarchy-theme-set` calls `omarchy-theme-bg-next` after applying a theme.

### `neovim.lua`

LazyVim spec snippet that switches the colorscheme when the theme is active. Example:

```lua
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
```

### `vscode.json`

VS Code theme binding. Extension must already be installed (or be installable from Marketplace).

```json
{
  "name": "Tokyo Night",
  "extension": "enkia.tokyo-night"
}
```

### `btop.theme`

Full btop theme file (not generated from palette — btop has its own format with semantic keys like `main_bg`, `cpu_start`, `temp_mid`). Easiest path: copy from a stock theme and replace the hex values. See `~/.local/share/omarchy/themes/<any>/btop.theme`.

If `colors.toml` is present the default `btop.theme.tpl` will be rendered automatically — only ship a hand-written `btop.theme` if you want something different from the templated result.

### `preview.png`

Screenshot of the theme applied (Hyprland desktop with terminal, Waybar, a browser). Used by `omarchy-theme-list` previews and the theme picker. Not functional; cosmetic.

### `keyboard.rgb`

Three comma-separated decimal RGB values on a single line (`242,240,229`). Used by supported RGB keyboards. Optional — only ship if targeting hardware.

## Per-app override files

Any file named after a template (`waybar.css`, `alacritty.toml`, `hyprland.conf`, `mako.ini`, `walker.css`, `swayosd.css`, `kitty.conf`, `ghostty.conf`, `hyprlock.conf`, `chromium.theme`, `obsidian.css`) placed directly in the theme directory **replaces** the templated output for that app in this theme. Use this for per-theme tweaks the palette can't express (fonts, padding, opacity, extra CSS rules).

Example — custom Waybar CSS on top of the palette:

```css
/* ~/.config/omarchy/themes/my-theme/waybar.css */
@define-color foreground #cdd6f4;
@define-color background #181824;

window#waybar {
  border-bottom: 2px solid @foreground;
}
```

## Canonical workflow: creating a new theme

1. **Pick a base** — find the closest stock theme in `~/.local/share/omarchy/themes/` and copy it:

   ```bash
   cp -r ~/.local/share/omarchy/themes/tokyo-night ~/.config/omarchy/themes/my-theme
   rm ~/.config/omarchy/themes/my-theme/preview.png   # will regenerate
   ```

2. **Edit `colors.toml`** — update all 22 keys to the new palette. Keep the keys even if values match the base.

3. **Swap backgrounds** — replace files in `backgrounds/` with wallpapers that suit the palette. Keep numeric prefixes if you want a deterministic first pick.

4. **Decide light vs dark** — `touch light.mode` for light themes; delete it for dark.

5. **Update `icons.theme`** — pick a Yaru variant that matches the accent hue.

6. **Update `neovim.lua` / `vscode.json`** — point them at a matching editor colorscheme (or leave the base theme's entries if they still fit).

7. **Apply and iterate**:

   ```bash
   omarchy-theme-set my-theme
   ```

   This regenerates templates, restarts Waybar/swayosd/terminal/mako/btop, updates GNOME/browser/VSCode/Obsidian/keyboard, and fires the `theme-set` hook. All changes are live immediately.

8. **Inspect the rendered configs** at `~/.config/omarchy/current/theme/` — this is what the running apps are actually reading. Useful for debugging why one app looks off while the rest look right.

9. **Take a `preview.png`** once satisfied.

## Canonical workflow: overlaying a stock theme

To tweak one aspect of a stock theme without forking it:

```bash
mkdir -p ~/.config/omarchy/themes/tokyo-night     # same slug as stock
# Drop ONLY the files you want to override:
echo "Yaru-blue" > ~/.config/omarchy/themes/tokyo-night/icons.theme
```

Everything else still comes from the stock theme. Confirm the override by reading `~/.config/omarchy/current/theme/` after `omarchy-theme-set tokyo-night`.

## Publishing a theme

Omarchy installs third-party themes via git clone. Requirements:

1. Repository name follows `omarchy-<slug>-theme` — `omarchy-theme-install` strips the `omarchy-` prefix and `-theme` suffix to derive the slug.
2. Theme directory contents live at the **root** of the repo (no nested folder).
3. Users install with:

   ```bash
   omarchy-theme-install https://github.com/<user>/omarchy-<slug>-theme
   ```

   That clones the repo into `~/.config/omarchy/themes/<slug>/` and immediately runs `omarchy-theme-set <slug>`.

4. Submit to the official extras list by contacting the Omarchy maintainer on Discord (see the extra-themes manual page).

Do NOT commit `preview.png` bigger than a few hundred KB — it's cosmetic and hurts clone time.

## Visual authoring

Aether (launched via `Super + Space` → "Aether") is Omarchy's GUI for picking colors and finding backgrounds. Use it when the user wants to design a palette interactively rather than hand-writing `colors.toml`.

## Validation checklist

Before calling a theme done:

- [ ] `colors.toml` parses (no trailing commas, all values quoted)
- [ ] All 22 palette keys present
- [ ] At least one image in `backgrounds/`
- [ ] `icons.theme` (if present) is a single line with a valid Yaru variant
- [ ] `light.mode` present ↔ theme is actually light
- [ ] `omarchy-theme-set <slug>` completes without errors
- [ ] Hyprland border, Waybar, terminal, mako, and btop all pick up the new colors
- [ ] `~/.config/omarchy/current/theme/` contains the rendered configs you expect

## Common pitfalls

- **Directory name has spaces or capitals** — `omarchy-theme-set` slugs the argument, but the directory must already be the slug form or it won't be found.
- **Editing in `~/.local/share/omarchy/themes/`** — these get wiped or overwritten by `omarchy-update`. Always work in `~/.config/omarchy/themes/`.
- **Forgot `light.mode` on a light theme** — GNOME/Adwaita stays dark, producing a jarring mismatch against a pale Waybar.
- **`colors.toml` missing keys** — templates still render but emit literal `{{ key }}` strings into configs; grep `~/.config/omarchy/current/theme/` for `{{` after theme-set to catch this.
- **Shipping both a template override and an unchanged `colors.toml`** — the override wins silently; changes to palette colors won't appear in that app until the override is deleted.
- **Per-app override file has wrong filename** — must match the template output exactly (`waybar.css`, not `waybar.style.css`).
- **btop.theme using short hex** — btop wants full `#RRGGBB`.
- **Missing `backgrounds/` directory** — `omarchy-theme-bg-next` at the end of theme-set will fail silently and the wallpaper won't change.

## Useful commands

```bash
omarchy-theme-list                    # all available themes
omarchy-theme-current                 # currently applied theme
omarchy-theme-set <slug>              # apply a theme (regenerates templates, restarts apps)
omarchy-theme-bg-next                 # cycle to next background in current theme
omarchy-theme-install <git-url>       # clone + apply a third-party theme
omarchy-theme-set-templates           # re-render templates from colors.toml (rarely needed manually)

# Inspect what's actually active
ls   ~/.config/omarchy/current/theme/
cat  ~/.config/omarchy/current/theme/colors.toml
cat  ~/.config/omarchy/current/theme.name
```

## References

- Manual — Making your own theme: https://learn.omacom.io/2/the-omarchy-manual/92/making-your-own-theme
- Manual — Extra themes: https://manuals.omamix.org/2/the-omarchy-manual/90/extra-themes
- Stock themes (read-only reference): `~/.local/share/omarchy/themes/`
- Template sources: `~/.local/share/omarchy/default/themed/*.tpl`
- Theme-set logic: `~/.local/share/omarchy/bin/omarchy-theme-set`, `omarchy-theme-set-templates`
