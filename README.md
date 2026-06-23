<div align="center">
  <h1>Hyprtasking</h1>
  <p>Powerful workspace management plugin, packed with features.</p>
</div>

> [!Important]
> - Supports Hyprland release `v0.46.2-v0.55.x`.

https://github.com/user-attachments/assets/8d6cdfd2-2b17-4240-a117-1dbd2231ed4e

#### [Jump To Installation](#Installation)

#### [See Configuration](#Configuration)

## Roadmap

- [ ] Modular Layouts
    - [x] Grid layout
    - [x] Linear layout
    - [ ] Minimap layout
- [x] Mouse controls
    - [x] Exit into workspace (hover, click)
    - [x] Drag and drop windows
- [ ] Keyboard controls
    - [x] Switch workspaces with direction
    - [ ] Switch workspaces with absolute number
- [x] Multi-monitor support (tested)
- [x] Monitor scaling support (tested)
- [x] Animation support
- [x] Configurability
    - [x] Overview exit behavior
    - [x] Number of visible workspaces
    - [x] Custom workspace layouts
    - [x] Toggle behavior
    - [x] Toggle keybind
- [x] Touchpad gesture support
- [ ] Touchscreen support
- [x] Overview layers

## Installation

### Hyprpm

```
hyprpm add https://github.com/raybbian/hyprtasking
hyprpm enable hyprtasking
```

### Nix

Add hyprtasking to your flake inputs
```nix
# flake.nix
{
  inputs = {
    hyprland.url = "github:hyprwm/Hyprland/v0.49.0";

    hyprtasking = {
      url = "github:raybbian/hyprtasking";
      inputs.hyprland.follows = "hyprland";
    };
  };
  # ...
}

```

Include the plugin in the hyprland home manager options

```nix
# home.nix
{ inputs, ... }:
{
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hyprtasking.packages.${pkgs.system}.hyprtasking
    ];
  }
}
```

### Manual

To build, have hyprland headers installed on the system and then:

```
meson setup build
cd build && meson compile
```

Then use `hyprctl plugin load` to load the absolute path to the `.so` file:

```
hyprctl plugin load "$(realpath libhyprtasking.so)"
```

## Usage

### Opening Overview

- Bind `hyprtasking:toggle, all` to a keybind to open/close the overlay on all monitors.
- Bind `hyprtasking:toggle, cursor` to a keybind to open the overlay on one monitor and close on all monitors.
- Swipe up/down on a touchpad device to open/close the overlay on one monitor.
- See [below](#Configuration) for configuration options.

### Interaction

- Workspace Transitioning:
    - Open the overlay, then use **right click** to switch to a workspace
    - Use the directional dispatchers `hyprtasking:move` to switch to a workspace
- Window management:
    - **Left click** to drag and drop windows around

## Configuration

Example below:

```lua
hl.bind("SUPER + TAB", function() hl.plugin.hyprtasking.toggle("cursor") end)
hl.bind("SUPER + SPACE", function() hl.plugin.hyprtasking.toggle("all") end)

-- escape closes the overview if it's open
hl.bind("escape", function()
  if hl.plugin.hyprtasking.is_active() then
    hl.plugin.hyprtasking.toggle('all')
  end
end, { non_consuming = true })

hl.bind("SUPER + X", function() hl.plugin.hyprtasking.killhovered() end)

hl.bind("SUPER + H", function() hl.plugin.hyprtasking.move("left") end)
hl.bind("SUPER + J", function() hl.plugin.hyprtasking.move("down") end)
hl.bind("SUPER + K", function() hl.plugin.hyprtasking.move("up") end)
hl.bind("SUPER + L", function() hl.plugin.hyprtasking.move("right") end)

hl.bind("SUPER + A", function() hl.plugin.hyprtasking.move("out") end)
hl.bind("SUPER + SHIFT + A", function() hl.plugin.hyprtasking.movewindow("out") end)

hl.bind("SUPER + CTRL + 1", function() hl.plugin.hyprtasking.setlayer(1) end)
hl.bind("SUPER + CTRL + 2", function() hl.plugin.hyprtasking.setlayer(2) end)

hl.config({
  plugin = {
    hyprtasking = {
      layout = "grid", -- overview layout: "grid" or "linear"

      gap_size = 10, -- gap between workspace tiles, logical px
      bg_color = 0xff26233a, -- overlay background color
      border_size = 2, -- workspace tile border width, logical px
      exit_on_hovered = false, -- close into hovered workspace instead of active workspace
      warp_on_move_window = 1, -- warp cursor with `hyprtasking:movewindow`
      close_overview_on_reload = false, -- close/rebuild overview on config reload
      full_render = true, -- full-res offscreen rendering, better quality, heavier GPU cost

      labels = {
        display_label = true, -- draw workspace labels
        position = "top_left", -- tile anchor: top_left/top/top_right/mid_left/mid/mid_right/bottom_left/bottom/bottom_right
        font = "", -- font family, empty = Hyprland default
        font_size = 14, -- points
        text_opacity = 100, -- 0..100
        text_color = "", -- hex, empty = renderer default
        background = false, -- draw label background panel
        background_color = "", -- hex, empty = plugin bg_color
        background_opacity = 100, -- 0..100
      },

      -- for other mouse buttons see <linux/input-event-codes.h>
      drag_button = 0x110,   -- hold to drag window in overview
      select_button = 0x111, -- click to exit into hovered workspace

      gestures = {
        enabled = true, -- enable touchpad gestures
        move_fingers = 3, -- finger count for workspace movement gesture
        move_distance = 300, -- swipe distance mapped to one workspace width
        open_fingers = 4, -- finger count for open/close gesture
        open_distance = 300, -- swipe distance threshold for open/close
        open_positive = true, -- true: positive swipe opens, false: closes
      },

      grid = {
        rows = 3, -- grid row count
        cols = 3, -- grid column count
        loop = false, -- wrap horizontal/vertical navigation at edges
        layers = 2, -- extra depth dimension for grid
        loop_layers = true, -- wrap layer navigation at ends
        gaps_use_aspect_ratio = true, -- scale vertical gaps by monitor aspect ratio
      },

      linear = {
        top = false, -- place strip at top instead of bottom
        height = 400, -- strip height, logical px
        scroll_speed = 1.0, -- mouse wheel / swipe speed multiplier
        blur = false, -- blur dimmed area outside strip
      },

      monitors = {
        {
          output = "eDP-1", -- selector: connector or `desc:...`
          labels = {
            display_label = true, -- per-monitor override
            position = "top_right",
            text_color = "#ffffff",
          },
          grid = {
            rows = 3, -- per-monitor override
            cols = 3,
          },
        },
        {
          output = "DP-1",
          labels = {
            display_label = false,
          },
          grid = {
            rows = 2,
            cols = 2,
          },
        },
      },
    }
  },
})

```

`monitors[*].output` accepts either connector names such as `DP-1` / `eDP-1` or
Hyprland `desc:...` selectors. `desc:` matching follows Hyprland monitor-rule
semantics, so selector matches monitor descriptions by prefix. All other
per-monitor options stay alongside `output`, nested in same normal config shape
(`labels = { ... }`, `grid = { ... }`, `linear = { ... }`, etc).

<details><summary>
Click here to see the old hyprlang syntax
</summary>

```
bind = SUPER, tab, hyprtasking:toggle, cursor
bind = SUPER, space, hyprtasking:toggle, all
# NOTE: the lack of a comma after hyprtasking:toggle!
bind = , escape, hyprtasking:if_active, hyprtasking:toggle cursor


bind = SUPER, X, hyprtasking:killhovered

bind = SUPER, H, hyprtasking:move, left
bind = SUPER, J, hyprtasking:move, down
bind = SUPER, K, hyprtasking:move, up
bind = SUPER, L, hyprtasking:move, right

bind = SUPER, A, hyprtasking:move, out
bind = SUPER SHIFT, A, hyprtasking:movewindow, out

bind = SUPER CTRL, 1, hyprtasking:setlayer, 1
bind = SUPER CTRL, 2, hyprtasking:setlayer, 2

plugin {
    hyprtasking {
        layout = grid

        gap_size = 10
        bg_color = 0xff26233a
        border_size = 2
        exit_on_hovered = false
        warp_on_move_window = 1
        close_overview_on_reload = false
        full_render = true  # might lag

        labels {
            display_label = true
            position = top_left
            font = ""
            font_size = 14
            text_opacity = 100
            text_color = ""
            background = false
            background_color = ""
            background_opacity = 100
        },

        drag_button = 0x110 # left mouse button
        select_button = 0x111 # right mouse button
        # for other mouse buttons see <linux/input-event-codes.h>

        gestures {
            enabled = true
            move_fingers = 3
            move_distance = 300
            open_fingers = 4
            open_distance = 300
            open_positive = true
        }

        grid {
            rows = 3
            cols = 3
            loop = false
            layers = 2
            loop_layers = true
            gaps_use_aspect_ratio = true
        }

        linear {
            top = false
            height = 400
            scroll_speed = 1.0
            blur = false
        }
    }
}
```

</details>

### Dispatchers

- `hyprtasking:if_active, ARG` takes in a dispatch command (one that would be used after `hyprctl dispatch ...`) that will be dispatched only if the cursor overview is active.
    - Allows you to use e.g. `escape` to close the overview when it is active. See the [example config](#configuration) for more info.

- `hyprtasking:if_not_active, ARG` same as above, but if the overview is not active.

- `hyprtasking:toggle [, ARG]` takes 1 optional argument that is either `cursor` or `all`
    - if the argument is `all`, then
        - if all overviews are hidden, then all overviews will be shown
        - otherwise all overviews will be hidden
    - if the argument is `cursor` or no argument is given, then
        - if current monitor's overview is hidden, then it will be shown
        - otherwise all overviews will be hidden

- `hyprtasking:move, ARG` takes in 1 argument that is one of `up`, `down`, `left`, `right`, `in`, `out`
    - when dispatched, hyprtasking will switch workspaces with a nice animation

- `hyprtasking:movewindow, ARG` takes in 1 argument that is one of `up`, `down`, `left`, `right`, `in`, `out`
    - when dispatched, hyprtasking will 1. move the hovered window to the workspace in the given direction relative to the window, and 2. switch to that workspace.
<details><summary>
<b>Click here to see the coordinate space</b>
</summary>

<div align="center">
<img src="https://github.com/user-attachments/assets/2c5ddf85-2a0a-412d-8ade-c2606fa920d3" width=70% height=70% alt="Coordinates">
</div>
</details>

- `hyprtasking:setlayer, ARG` takes in 1 optional argument that specifies the direction of movement across layers.
    - if provided, the argument has to start with `+` or `-` to take effect. For example: `+1`, `-3`
    - no arguments has the same effect as `+1`
    - when dispatched, hyprtasking will move you through the layers in the specified direction
    - if plugin option `grid:loop_layers` is enabled, will loop the layers if next requested layer is out of bounds (not in the range form 0 to `grid:layers`)

- `hyprtasking:setlayerwindow, ARG` takes in 1 optional argument that specifies the direction of movement across layers.
    - when dispatched, hyprtasking will do the same as `hyprtasking:setlayer, ARG` and also move the window through layers

- `hyprtasking:killhovered` behaves similarly to the standard `killactive` dispatcher with focus on hover
    - when dispatched, hyprtasking will close the currently hovered window, useful when the overview is active.
    - this dispatcher is designed to **replace** `hl.dsp.close()`, it will work even when the overview is **not active**.

### Config Options

**NEW: Labels**

All options should are prefixed with `plugin:hyprtasking:`.

| Option | Type | Description | Default |
| --- | --- | --- | --- |
| `layout` | `string` | The layout to use, either `grid` or `linear` | `grid` |
| `bg_color` | `int` | The color of the background of the overlay | `0x000000FF` |
| `gap_size` | `float` | The width in logical pixels of the gaps between workspaces | `8.f` |
| `border_size` | `float` | The width in logical pixels of the borders around workspaces | `4.f` |
| `exit_on_hovered` | `int` | If true, hiding the workspace will exit to the hovered workspace instead of the active workspace. | `false` |
| `warp_on_move_window` | `int` | Works the same as `cursor:warp_on_change_workspace` (see [wiki](https://wiki.hypr.land/Configuring/Variables/#cursor)) but with `hyprtasking:movewindow` dispathcer. <br> `cursor:warp_on_change_workspace` works only with `hyprtasking:move` dispathcer | `1` |
| `close_overview_on_reload` | `int` | Whether to close and rebuild overview state when config reloads | `true` |
| `full_render` | `bool` | Render each workspace preview at full monitor resolution before scaling into tile. Higher quality, heavier GPU cost | `true` |
| `drag_button` | `int` | The mouse button to use to drag windows around | `0x110` |
| `select_button` | `int` | The mouse button to use to select a workspace | `0x111` |
| `labels:display_label` | `bool` | Whether or not to draw workspace labels | `true` |
| `labels:position` | `string` | Label anchor inside each workspace tile. Valid values: `top_left`, `top`, `top_right`, `mid_left`, `mid`, `mid_right`, `bottom_left`, `bottom`, `bottom_right` | `top_left` |
| `labels:font` | `string` | Font family passed to Hyprland's text renderer | `""` |
| `labels:font_size` | `int` | Label font size in points | `14` |
| `labels:text_opacity` | `int` | Label text opacity from `0` to `100` | `100` |
| `labels:text_color` | `string` | Hex color for the label text | `""` |
| `labels:background` | `bool` | Whether to draw a rounded background behind the label | `false` |
| `labels:background_color` | `string` | Hex color for the label background | `""` |
| `labels:background_opacity` | `int` | Background opacity from `0` to `100` | `100` |
| `monitors` | `lua table` | Lua-only list of per-monitor overrides. Each entry needs `output = "<name or desc:...>"`; omitted keys fall back to the global plugin config. | `{}` |
| `gestures:enabled` | `int` | Whether or not to enable gestures | `true` |
| `gestures:move_fingers` | `int` | The number of fingers to use for the "move" gesture | `3` |
| `gestures:move_distance` | `float` | How large of a swipe on the touchpad corresponds to the width of a workspace | `300.f` |
| `gestures:open_fingers` | `int` | The number of fingers to use for the "open" gesture | `4` |
| `gestures:open_distance` | `float` | How large of a swipe on the touchpad is needed for the "open" gesture | `300.f` |
| `gestures:open_positive` | `int` | `true` if swiping up should open the overlay, `false` otherwise | `true` |
| `grid:rows` | `int` | The number of rows to display on the grid overlay | `3` |
| `grid:cols` | `int` | The number of columns to display on the grid overlay | `3` |
| `grid:loop` | `int` | When enabled, moving right at the far right of the grid will wrap around to the leftmost workspace, etc. | `false` |
| `grid:layers` | `int` | The number of layers for grid layout, the third dimension | `1` |
| `grid:loop_layers` | `int` | When enabled, moving back on the first layer will wrap around to the last layer. The reverse also works | `true` |
| `grid:gaps_use_aspect_ratio` | `int` | When enabled, vertical gaps will be scaled to match the monitor's aspect ratio | `false` |
| `linear:top` | `int` | Whether or not to position the overview on top of the screen | `false` |
| `linear:blur` | `int` | Whether or not to blur the dimmed area | `false` |
| `linear:height` | `float` | The height of the linear overlay in logical pixels | `300.f` |
| `linear:scroll_speed` | `float` | Scroll speed modifier. Set negative to flip direction | `1.f` |

<sup>FYI, "ARG" does not refer to any minecraft ARG. Why would you even ask that?
Eww</sup>

**NEW: Per monitor configuration**

Per-monitor label overrides are configured with the nested `monitors` table in Lua config:

```lua
hl.config({
  plugin = {
    hyprtasking = {
      monitors = {
        {
          output = "eDP-1",
          labels = { display_label = true, position = "top_right", text_color = "#ffffff" },
          grid = { rows = 3, cols = 3 },
        },
        {
          output = "DP-1",
          labels = { display_label = false },
          grid = { rows = 2, cols = 2 },
        },
      },
    },
  },
})
```

Put per-monitor overrides directly in monitor entry. Do not nest label options
inside `grid = { ... }` or other unrelated subtables.

Monitor overrides fall back to the global plugin config when a key is omitted.
Supported override keys mirror the normal plugin config shape, for example `layout`, `gap_size`, `bg_color`, `drag_button`, nested `labels = { ... }`, nested `gestures = { ... }`, nested `grid = { ... }`, and nested `linear = { ... }`.

**NEW: Optional workspace-name generator config**

Repo now includes optional Hyprland Lua examples under:

* [`.config/hypr/hyprland.lua`](.config/hypr/hyprland.lua)
* [`.config/hypr/custom/general.lua`](.config/hypr/custom/general.lua)
* [`.config/hypr/custom/workspace-generator.lua`](.config/hypr/custom/workspace-generator.lua)
* [`.config/hypr/custom/hyprtasking.lua`](.config/hypr/custom/hyprtasking.lua)

The important template is [`.config/hypr/custom/general.lua`](.config/hypr/custom/general.lua). It wires monitor
rules and workspace rules through [`workspace-generator.lua`](.config/hypr/custom/workspace-generator.lua), so each monitor can
get its own sequential workspace name family:


- ultrawide: `A1`, `A2`, `A3`, ...
- aux: `B1`, `B2`, `B3`, ...
- laptop: `C1`, `C2`, `C3`, ...

That generator is optional, but it pairs well with Hyprtasking labels because
workspace labels now render the real workspace name, not only numeric IDs.

The naming template lives in:

```lua
format = {
  single = "{prefix}{label}{set_label}{suffix}",
  repeated = "{prefix}{label}{set_label}{set_id}{suffix}",
}
```

With per-monitor groups like:

```lua
{
  output = "desc:Microstep MSI MD342CQP 0000000000001",
  workspaces = {
    label = "A",
    sets = {
      { count = 9 },
    },
  },
}
```

That produces sequential names per monitor. Swap `label = "A"` for `B` / `C`
to get `B1..Bn` and `C1..Cn`. You can also change the format to produce forms
such as `A-1`, `A:Chat:1`, or `M-A1`.
