-------------------------------
-- MONITORS + WORKSPACES --
-------------------------------

-- Generator lives in:
--   ~/.config/hypr/custom/workspace-generator.lua
local workspace_generator = require("custom.workspace-generator")

-- Defaults for all workspace groups.
-- Any value here can be overridden inside:
--   workspaces = { ... }
-- or inside a specific set:
--   sets = { { ... } }
local defaults = {
  layout = "dwindle",
  persistent = false,

  prefix = "",
  suffix = "",

  -- Workspace name format.
  --
  -- Available tokens:
  --   {prefix}    text before the name
  --   {label}     group/workspace-group label, e.g. A / B / C
  --   {set_label} optional set label, e.g. Work / Chat / Media
  --   {set_id}    repeated set ID; empty if the label+set_label appears once
  --   {suffix}    text after the name
  --   {slot}      local workspace slot inside this monitor group
  --   {id}        global Hyprland workspace ID
  --   {output}    monitor output selector
  --
  -- No dash/separator is forced by the generator.
  -- Add separators directly in the format if you want them.
  --
  -- Examples:
  --   "{label}{set_id}"                    -> A1
  --   "{label}-{set_id}"                   -> A-1
  --   "{label}{set_label}{set_id}"         -> AChat1
  --   "{label}:{set_label}:{set_id}"       -> A:Chat:1
  --   "{prefix}{label}{set_label}{set_id}{suffix}"
  --                                        -> M-AChat1 α
  format = {
    single = "{prefix}{label}{set_label}{suffix}",
    repeated = "{prefix}{label}{set_label}{set_id}{suffix}",
  },
}

WorkspaceModel = workspace_generator.apply({
  defaults = defaults,

  groups = {
    ----------------------
    -- Main ultrawide --
    ----------------------
    {
      -- Everything except `workspaces = { ... }` is passed to hl.monitor().
      output = "desc:Microstep MSI MD342CQP 0000000000001",
      mode = "3440x1440@120.00",
      position = "0x0",
      scale = "1",

      workspaces = {
        label = "A",
        layout = "dwindle",

        -- Optional per-group modifiers.
        --
        -- Examples:
        --   prefix = "M-"     -> M-A1
        --   suffix = " α"     -> A1 α
        --   prefix = "M-", suffix = " α"
        --                    -> M-A1 α
        prefix = "",
        suffix = "",

        -- Optional layout-specific options.
        --
        -- Example:
        --   layout = "scrolling",
        --   layout_opts = {
        --     direction = "right",
        --   },
        --
        -- If omitted, no layout_opts are added.
        -- layout_opts = {},

        -- Sets define local workspace slots.
        --
        -- Supported forms:
        --
        --   { count = 9 }
        --     Creates the next 9 local slots.
        --
        --   { range = { 1, 3 } }
        --     Uses local slots 1, 2, 3.
        --
        --   { slots = { 1, 5, 9 } }
        --     Uses exactly local slots 1, 5, 9.
        --
        -- Optional set labels:
        --
        --   { set_label = "Chat", count = 3 }
        --
        -- With format:
        --   repeated = "{label}{set_label}{set_id}"
        --
        -- Gives:
        --   AChat1, AChat2, AChat3
        sets = {
          { count = 9 },
        },
      },
    },

    -----------------
    -- AUX display --
    -----------------
    {
      output = "desc:Invalid Vendor Codename - RTK 0x1920 0x19201200",
      mode = "1920x1200@59.95",
      position = "1120x1440",
      scale = "1",
      transform = 3,

      workspaces = {
        label = "B",
        layout = "dwindle",

        sets = {
          { count = 4 },
        },
      },
    },

    ----------------------
    -- Laptop display --
    ----------------------
    {
      output = "desc:Samsung Display Corp. 0x41AB",
      mode = "2560x1600@120.00",
      position = "2320x1440",
      scale = "1.25",

      workspaces = {
        label = "C",
        layout = "dwindle",

        sets = {
          { count = 9 },
        },
      },
    },
  },
})

-------------------------------
-- SCROLLING LAYOUT KEYBINDS --
-------------------------------

-- -- Move the visible tape by one column.
-- hl.bind("SUPER + CTRL + ALT + mouse_down", hl.dsp.layout("move -col"), {
--     description = "Scrolling: Move tape forward",
-- })
-- 
-- hl.bind("SUPER + CTRL + ALT + mouse_up", hl.dsp.layout("move +col"), {
--     description = "Scrolling: Move tape backward",
-- })
-- 
-- -- Keyboard equivalent.
-- hl.bind("SUPER + CTRL + ALT + Page_Down", hl.dsp.layout("move +col"), {
--     repeating = true,
--     description = "Scrolling: Move tape forward",
-- })
-- 
-- hl.bind("SUPER + CTRL + ALT + Page_Up", hl.dsp.layout("move -col"), {
--     repeating = true,
--     description = "Scrolling: Move tape backward",
-- })


--------------------
-- General Config --
--------------------


hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 4,
        gaps_workspaces = 2,
        layout = "dwindle",
        border_size = 3,
        resize_on_border = true,
        no_focus_fallback = true,
        allow_tearing = false,
        snap = {
            enabled = true,
            window_gap = 10,
            monitor_gap = 10,
            respect_gaps = true,
        },
    },

	  ----------------------
	  -- Scrolling Layout --
	  ----------------------

    scrolling = {
        -- Single-window workspaces use the full monitor.
        fullscreen_on_one_column = true,

        -- Default column width.
        -- 0.5 = two columns visible.
        -- 0.6/0.667 = more focused, less cramped.
        -- 0.8 = large main-column style.
        column_width = 0.667,

        -- 0 = center focused column.
        -- 1 = fit focused column into view.
        focus_fit_method = 1,

        -- Automatically move the tape when focus changes.
        follow_focus = true,

        -- If follow_focus is true, only auto-scroll if less than this much
        -- of the target window is visible.
        follow_min_visible = 0.35,

        -- Presets used by:
        --   hl.dsp.layout("colresize +conf")
        --   hl.dsp.layout("colresize -conf")
        explicit_column_widths = "0.333, 0.5, 0.667, 0.8, 1.0",

        -- Let directional focus wrap inside the tape.
        wrap_focus = true,

        -- Let column swapping wrap from first <-> last.
        wrap_swapcol = true,

        -- Global fallback direction.
        -- Per-workspace `layout_opts.direction` can override this.
        direction = "right",
    },

    ---------------------
    -- Dwindle Layout --
    ---------------------

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
        precise_mouse_move = true,
    },

    ----------------
    -- Decoration --
    ----------------

    decoration = {
        rounding_power = 2.5,
        rounding = 18,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        dim_modal = true,
        dim_inactive = true,
        dim_strength = 0.2,
        blur = {
            enabled = true,
            size = 10,
            passes = 2,
            new_optimizations = true,
            noise = 0.15,
            xray = true,
            brightness = 1.2,
            contrast = 0.9,
            vibrancy = 0.2,
            vibrancy_darkness = 0.3,
        },
    },

    animations = {
        enabled = true,
    },

    ------------------
    -- Input Config --
    ------------------
    input = {
        kb_layout = "us,no",
        kb_options = "grp:win_space_toggle",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        left_handed = false,
        follow_mouse = 2,
        off_window_axis_events = 3,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.5,
        },
        touchdevice = {
            transform = 3,
            output = "desc:Invalid Vendor Codename - RTK 0x1920 0x19201200",
        },
        tablet = {
            transform = 3,
            output = "desc:Invalid Vendor Codename - RTK 0x1920 0x19201200",
            relative_input = true,
            absolute_region_position = true,
        },
    },

    cursor = {
        zoom_factor = 1,
        zoom_rigid = false,
        zoom_detached_camera = true,
        hotspot_padding = 1,
        no_hardware_cursors = 1,
        no_break_fs_vrr = false,
        min_refresh_rate = 15,
        use_cpu_buffer = false,
        default_monitor = "Microstep MSI MD342CQP 0000000000001",
        sync_gsettings_theme = false,
        no_warps = false,
    },
    --------------------------
    -- All other categories --
    --------------------------
    misc = {
        middle_click_paste = false,
        font_family = "Terminus TTF",
        render_unfocused_fps = 30,
    },

    debug = {
        disable_logs = false,
    },

    xwayland = {
        enabled = true,
        force_zero_scaling = true,
        use_nearest_neighbor = true,
    },
})