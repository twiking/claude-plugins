# twiking-claude-plugins

A personal [Claude Code](https://claude.com/claude-code) plugin marketplace containing plugins I use across my machines.

## Installation

Add this repo as a marketplace in Claude Code:

```
/plugin marketplace add twiking/twiking-claude-plugins
```

Then install individual plugins:

```
/plugin install claude-status@twiking-claude-plugins
/plugin install waybar@twiking-claude-plugins
```

## Plugins

### `claude-status`

Tracks whether Claude is actively working in a session and writes the current state to `<git-root>/.claude/claude-status/data.json`. Useful for external tools (status bars, notifiers, dashboards) that want to surface Claude's activity.

States written: `Active`, `Inactive`, `PermissionRequest`.

The status file looks like:

```json
{
  "status": "Active",
  "session_id": "…",
  "cwd": "/path/to/project",
  "timestamp": "2026-04-11T12:34:56Z"
}
```

Implemented via Claude Code hooks (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `Stop`, `Notification`, `SessionEnd`) that invoke a small shell script. Requires `jq` and `git` on `PATH`.

### `waybar`

A skill for configuring, styling, and debugging [Waybar](https://github.com/Alexays/Waybar) — the Wayland status bar used by Sway, Hyprland, River, Niri, and other wlroots-based compositors. Activates when editing files under `~/.config/waybar/` or when adding/removing modules, tweaking CSS, fixing icon/font issues, or writing custom modules.

## Repository layout

```
.claude-plugin/
  marketplace.json      # marketplace manifest
plugins/
  claude-status/        # session activity tracker (hooks)
  waybar/               # Waybar configuration skill
```
