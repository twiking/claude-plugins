---
name: waybar
description: Use when configuring, styling, or debugging Waybar — the Wayland status bar used by Sway, Hyprland, River, Niri, etc. Trigger when editing files under ~/.config/waybar/ (config, config.jsonc, style.css), adding/removing modules, changing bar position/layout, fixing icon/font issues, reloading the bar, or writing custom modules.
---

# Waybar

Waybar is a highly customizable Wayland status bar for wlroots-based compositors (Sway, Hyprland, River, Niri, Wayfire, dwl, etc.).

## When to use this skill

Use this skill when the user asks you to:

- Edit, create, or debug files under `~/.config/waybar/`
- Add, remove, or reorder modules (clock, battery, network, workspaces, pulseaudio, tray, custom, ...)
- Change bar position, height, layering, or multi-monitor output targeting
- Style the bar with CSS (colors, fonts, spacing, module states)
- Fix missing icons, font-width jitter, or hover/focus glitches
- Reload the bar after changes or toggle its visibility
- Write custom modules (shell scripts producing JSON)

## Config file layout

Waybar reads, in order, from:

1. `$XDG_CONFIG_HOME/waybar/`
2. `~/.config/waybar/`
3. `~/waybar/`
4. `/etc/xdg/waybar/`

The two files that matter:

- **`config`** or **`config.jsonc`** — JSONC (JSON with comments). Defines bars and modules.
- **`style.css`** — GTK CSS subset. Styles the bar and every module.

Optional: `style-light.css` / `style-dark.css` to follow system theme.

## Config structure

A single object creates one bar. An array creates multiple bars (one per object). Each bar object has top-level bar options plus per-module config blocks keyed by module id.

```jsonc
{
  // Bar options
  "layer": "top",              // "top" draws over windows, "bottom" behind them
  "position": "top",           // "top" | "bottom" | "left" | "right"
  "height": 30,
  "spacing": 4,                // gap between modules
  "margin": "4 8 0 8",         // CSS-style margins
  "output": ["DP-1", "!eDP-1"],// target displays; "!" excludes
  "name": "main",              // CSS class: window#waybar.main
  "ipc": true,                 // Sway/Hyprland IPC events
  "reload_style_on_change": true,
  "include": ["~/.config/waybar/modules.jsonc"],

  // Module placement
  "modules-left":   ["sway/workspaces", "sway/mode"],
  "modules-center": ["clock"],
  "modules-right":  ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],

  // Module configuration (keyed by module id)
  "clock": {
    "format": "{:%Y-%m-%d %H:%M}",
    "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
  },
  "battery": {
    "states": { "warning": 30, "critical": 15 },
    "format": "{capacity}% {icon}",
    "format-charging": "{capacity}% ",
    "format-icons": ["", "", "", "", ""]
  },
  "network": {
    "format-wifi": "{essid} ({signalStrength}%) ",
    "format-ethernet": "{ipaddr}/{cidr} ",
    "format-disconnected": "Disconnected ⚠"
  }
}
```

**Multiple instances of the same module** use `#` suffix — declare as `"battery#bat2"` in both the `modules-*` array and as a config key.

**Format strings** support Pango markup: `"<span color='#ff0000'>{}</span>"`.

**Actions**: every module accepts `on-click`, `on-click-right`, `on-click-middle`, `on-double-click`, `on-triple-click`, `on-scroll-up`, `on-scroll-down` to run shell commands.

## Built-in modules (common)

- **System**: `battery`, `cpu`, `memory`, `temperature`, `disk`, `load`, `backlight`
- **Network**: `network`, `bluetooth`
- **Audio**: `pulseaudio`, `wireplumber`, `jack`, `sndio`
- **Time**: `clock`
- **Compositor workspaces**: `sway/workspaces`, `hyprland/workspaces`, `river/tags`, `niri/workspaces`, `dwl/tags`, `wayfire/workspaces`
- **Window title**: `sway/window`, `hyprland/window`, `wlr/taskbar`
- **Media**: `mpd`, `mpris`
- **Misc**: `tray`, `idle_inhibitor`, `language`, `keyboard-state`, `custom/<name>`, `group`, `image`, `gamemode`, `upower`, `power-profiles-daemon`, `systemd-failed-units`, `privacy`

## Custom modules

A `custom/foo` module runs a shell command on an interval and displays its stdout, or reads a continuous JSON stream. Example:

```jsonc
"custom/weather": {
  "exec": "~/.config/waybar/scripts/weather.sh",
  "interval": 1800,
  "return-type": "json",          // "", "json", or "jsonc"
  "format": "{} {icon}",
  "format-icons": { "clear": "", "rain": "" },
  "tooltip": true,
  "on-click": "xdg-open https://wttr.in"
}
```

JSON return type expects: `{"text":"...","alt":"...","tooltip":"...","class":"...","percentage":0}`. The `alt` field selects a `format-icons` entry. The `class` becomes an extra CSS class on that module.

## Styling (style.css)

Waybar uses GTK's [limited CSS subset](https://docs.gtk.org/gtk3/css-properties.html) — no flexbox, no grid, no CSS variables via `--var` (use GTK `@define-color` or `@theme_*` instead). Transitions and simple animations work.

### Core selectors

```css
/* Whole bar */
window#waybar { background: #1e1e2e; color: #cdd6f4; }
window#waybar.hidden { opacity: 0.0; }
window#waybar.top    { border-bottom: 2px solid #89b4fa; }
window#waybar.main   { /* matches "name": "main" in config */ }

/* Per-output styling */
window#waybar.DP-1 * { font-size: 14px; }

/* Module groups */
.modules-left, .modules-center, .modules-right { padding: 0 8px; }

/* Individual modules — id matches module name, '/' and '#' become '-' */
#clock, #battery, #network, #pulseaudio, #cpu, #memory, #tray { padding: 0 10px; }
#workspaces button { padding: 0 6px; color: #cdd6f4; }
#workspaces button.focused { background: #89b4fa; color: #1e1e2e; }
#workspaces button:hover { background: rgba(255,255,255,0.1); }

/* State classes set by modules */
#battery.charging     { color: #a6e3a1; }
#battery.warning:not(.charging)  { color: #f9e2af; }
#battery.critical:not(.charging) { color: #f38ba8; animation: blink 1s steps(12) infinite alternate; }

/* Custom module extra class from JSON "class" field */
#custom-weather.rain { color: #89b4fa; }
```

### Practical styling tips

- **Fixed-width numbers** to stop jitter: use a monospace font and format specs like `"{usage:2}%"` or `"{:>3}%"`.
- **Remove GTK default button styling** on workspaces:
  ```css
  #workspaces button {
    box-shadow: inherit;
    text-shadow: inherit;
    min-width: 20px;
  }
  ```
- **Reduce CPU during animations**: `animation-timing-function: steps(12);` — GTK redraws on each step only.
- **Inspect live CSS**: `GTK_DEBUG=interactive waybar` opens the GTK inspector.
- **See the widget tree and classes**: `waybar -l debug`.

## Reloading and signals

| Action              | Command                          | Notes                          |
|---------------------|----------------------------------|--------------------------------|
| Reload config + CSS | `killall -SIGUSR2 waybar`        | v0.9.5+                        |
| Toggle visibility   | `killall -SIGUSR1 waybar`        |                                |
| Auto-reload CSS     | `"reload_style_on_change": true` | Watches `style.css` for writes |
| Restart cleanly     | `killall waybar && waybar &`     | Last resort                    |

## Icon fonts

The default config uses Font Awesome glyphs. Install `otf-font-awesome` (or Nerd Fonts) and set the font family in `style.css`:

```css
* {
  font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
  font-size: 13px;
}
```

If icons render as boxes (tofu), the font is missing — not a config bug.

## Common pitfalls

- **JSONC parse errors** — Waybar silently fails or falls back; run it in a terminal to see errors. Watch for trailing commas only being allowed in JSONC, not `config`.
- **Module not showing** — it must appear in a `modules-left/center/right` array AND have a config block (unless it accepts defaults).
- **Sway bar shows swaybar instead** — make sure `bar { swaybar_command waybar }` is set or use `exec waybar` and leave Sway's default bar block out.
- **`output` filtering not matching** — use exact compositor output names (`swaymsg -t get_outputs`, `hyprctl monitors`).
- **Multi-instance ids** — `"battery#bat2"` creates CSS id `#battery.bat2` (class), not a new `#` selector.
- **CSS not applying** — GTK CSS specificity rules; check `window#waybar #module` is more specific than `#module` alone.

## Debugging workflow

1. Run `waybar` in a terminal to see parse errors and log output.
2. For more detail: `waybar -l debug` (dumps widget tree with all CSS classes).
3. For CSS inspection: `GTK_DEBUG=interactive waybar`.
4. Validate JSONC: `jq . ~/.config/waybar/config.jsonc` (strip comments first if using plain `jq`).
5. After editing, reload with `killall -SIGUSR2 waybar` — no need to restart.

## References

- Configuration: https://github.com/Alexays/Waybar/wiki/Configuration
- Styling: https://github.com/Alexays/Waybar/wiki/Styling
- FAQ: https://github.com/Alexays/Waybar/wiki/FAQ
- Per-module pages: https://github.com/Alexays/Waybar/wiki (each module has its own wiki page with full option list — fetch the specific page when working on a specific module)
