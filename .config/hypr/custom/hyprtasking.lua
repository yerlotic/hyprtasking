-- ─────────────────────────────────────────────────────────────
-- Hyprtasking config
-- ─────────────────────────────────────────────────────────────

hl.config({
  plugin = {
    hyprtasking = {
      layout = "grid",

      gap_size = 10,
      bg_color = 0xff26233a,
      border_size = 2,
      exit_on_hovered = true,
      warp_on_move_window = 1,
      close_overview_on_reload = true,
      full_render = true, -- might lag


      labels = {
        display_label = true,
        -- position = "",
        font = "0xProto Nerd Font Mono",
        font_size = 20,
        text_opacity = 100,
        text_color = "#000000",
        background = true,
        background_color = "#FFFFFF",
        background_opacity = 50,
      },

      -- For other mouse buttons, see <linux/input-event-codes.h>
      drag_button = 0x111,   -- left mouse button
      select_button = 0x110, -- right mouse button

      gestures = {
        enabled = true,
        move_fingers = 3,
        move_distance = 300,
        open_fingers = 4,
        open_distance = 300,
        open_positive = true,
      },

      grid = {
        rows = 3,
        cols = 3,
        loop = true,
        layers = 1,
        loop_layers = false,
        gaps_use_aspect_ratio = true,
      },

      linear = {
        top = false,
        height = 400,
        scroll_speed = 1.0,
        blur = false,
      },

      monitors = {
        {
          output = "desc:Microstep MSI MD342CQP 0000000000001",
          grid = {
            rows = 3,
            cols = 3,
          },
        },
        {
          output = "desc:Samsung Display Corp. 0x41AB",
          grid = {
            rows = 3,
            cols = 3,
          },
        },
        {
          output = "desc:Invalid Vendor Codename - RTK 0x1920 0x19201200",
          layout = "grid",
          labels = {
            display_label = true,
            position = "top_right",
            font = "Google Sans",
            font_size = 20,
            text_opacity = 100,
            text_color = "#000000",
            background = true,
            background_color = "#FFFFFF",
            background_opacity = 50,
          },
          grid = {
            rows = 2,
            cols = 2,
          },
        },
      },
    },
  },
})

--#!
--##! Hyprtasking + directional window binds
--#

-- ─────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────

local directions = {
  { key = "Left",  hyprtasking = "left",  hyprland = "l", label = "Left"  },
  { key = "Right", hyprtasking = "right", hyprland = "r", label = "Right" },
  { key = "Up",    hyprtasking = "up",    hyprland = "u", label = "Up"    },
  { key = "Down",  hyprtasking = "down",  hyprland = "d", label = "Down"  },
}

local function ht_toggle(mode)
  return function()
    hl.plugin.hyprtasking.toggle(mode)
  end
end

local function ht_move(dir)
  return function()
    hl.plugin.hyprtasking.move(dir)
  end
end

local function ht_movewindow(dir)
  return function()
    hl.plugin.hyprtasking.movewindow(dir)
  end
end

local function ht_setlayer(layer)
  return function()
    hl.plugin.hyprtasking.setlayer(layer)
  end
end


-- ─────────────────────────────────────────────────────────────
-- Hyprtasking overview
-- ─────────────────────────────────────────────────────────────

hl.unbind("SUPER + TAB")

hl.bind("SUPER + TAB", ht_toggle("all"), {
  description = "Hyprtasking: Toggle overview",
})

-- Escape closes the overview if it is open.
hl.bind("escape", function()
  if hl.plugin.hyprtasking.is_active() then
    hl.plugin.hyprtasking.toggle("all")
  end
end, {
  non_consuming = true,
  description = "Hyprtasking: Close overview",
})

-- hl.bind("SUPER + X", function()
--   hl.plugin.hyprtasking.killhovered()
-- end, {
--   description = "Hyprtasking: Kill hovered",
-- })


-- ─────────────────────────────────────────────────────────────
-- Normal Hyprland window focus / movement
-- ─────────────────────────────────────────────────────────────

-- -- SUPER + Arrow
-- -- Focus normal window in direction.
-- for _, bind in ipairs(directions) do
--   hl.bind("SUPER + " .. bind.key, hl.dsp.focus({ direction = bind.hyprland }), {
--     description = "Window: Focus " .. bind.label,
--   })
-- end

-- SUPER + SHIFT + Arrow
-- Move normal window in direction.
for _, bind in ipairs(directions) do
  hl.bind("SUPER + SHIFT + " .. bind.key, hl.dsp.window.move({ direction = bind.hyprland }), {
    description = "Window: Move " .. bind.label,
  })
end


-- ─────────────────────────────────────────────────────────────
-- Hyprtasking directional controls
-- ─────────────────────────────────────────────────────────────

-- SUPER + CTRL + Arrow
-- Switch / move selection inside Hyprtasking.
for _, bind in ipairs(directions) do
  hl.bind("SUPER + CTRL + " .. bind.key, ht_move(bind.hyprtasking), {
    description = "Hyprtasking: Switch " .. bind.label,
  })
end

-- SUPER + ALT + Arrow
-- Move hovered/selected window inside Hyprtasking.
for _, bind in ipairs(directions) do
  hl.bind("SUPER + ALT + " .. bind.key, ht_movewindow(bind.hyprtasking), {
    description = "Hyprtasking: Move window " .. bind.label,
  })
end

-- SUPER + CTRL + A
-- Move Hyprtasking selection out.
hl.bind("SUPER + CTRL + A", ht_move("out"), {
  description = "Hyprtasking: Switch out",
})

-- SUPER + ALT + A
-- Move hovered/selected window out.
hl.bind("SUPER + ALT + A", ht_movewindow("out"), {
  description = "Hyprtasking: Move window out",
})


-- ─────────────────────────────────────────────────────────────
-- Hyprtasking layers
-- ─────────────────────────────────────────────────────────────

for layer = 1, 2 do
  hl.bind("SUPER + CTRL + " .. layer, ht_setlayer(layer), {
    description = "Hyprtasking: Set layer " .. layer,
  })
end


-- ─────────────────────────────────────────────────────────────
-- Mouse window controls
-- ─────────────────────────────────────────────────────────────

hl.unbind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })
hl.unbind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.unbind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
  mouse = true,
  description = "Window: Move",
})

hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), {
  mouse = true,
})

hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
  mouse = true,
  description = "Window: Resize",
})
