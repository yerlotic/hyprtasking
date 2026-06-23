-------------------------
-- Workspace Generator --
-------------------------

local M = {}

local function warn(message)
  if hl and hl.notification and hl.notification.create then
    hl.notification.create({
      text = "[workspace-generator] " .. message,
      timeout = 7000,
      icon = "warning",
    })
  else
    print("[workspace-generator] " .. message)
  end
end

local function merge(a, b)
  local result = {}

  for key, value in pairs(a or {}) do
    result[key] = value
  end

  for key, value in pairs(b or {}) do
    result[key] = value
  end

  return result
end

local function render(format, values)
  return (format or ""):gsub("{([%w_]+)}", function(key)
    local value = values[key]

    if value == nil then
      return ""
    end

    return tostring(value)
  end)
end

local function pick_format(format, repeated)
  if type(format) == "table" then
    if repeated then
      return format.repeated or format.single or "{prefix}{label}{set_label}{set_id}{suffix}"
    end

    return format.single or format.repeated or "{prefix}{label}{set_label}{suffix}"
  end

  return format or "{prefix}{label}{set_label}{suffix}"
end

local function monitor_rule(group)
  local rule = {}

  for key, value in pairs(group) do
    if key ~= "workspaces" then
      rule[key] = value
    end
  end

  return rule
end

local function set_slot(slots, slot, set)
  if slots[slot] ~= nil then
    warn("slot " .. tostring(slot) .. " is assigned more than once")
    return
  end

  slots[slot] = set
end

local function expand_sets(sets)
  local slots = {}
  local next_slot = 1
  local max_slot = 0

  for _, set in ipairs(sets or {}) do
    if set.count then
      for _ = 1, set.count do
        set_slot(slots, next_slot, set)
        max_slot = math.max(max_slot, next_slot)
        next_slot = next_slot + 1
      end

    elseif set.range then
      local first = set.range[1]
      local last = set.range[2]

      if not first or not last or first > last then
        warn("invalid range")
      else
        for slot = first, last do
          set_slot(slots, slot, set)
          max_slot = math.max(max_slot, slot)
        end
      end

    elseif set.slots then
      for _, slot in ipairs(set.slots) do
        set_slot(slots, slot, set)
        max_slot = math.max(max_slot, slot)
      end

    else
      warn("set has no count, range, or slots")
    end

    if max_slot >= next_slot then
      next_slot = max_slot + 1
    end
  end

  return slots, max_slot
end

function M.apply(config)
  local defaults = config.defaults or {}
  local groups = config.groups or {}

  local next_id = 1
  local key_totals = {}
  local key_ids = {}
  local used_names = {}
  local planned = {}

  local model = {
    ids = {},
    by_id = {},
    by_name = {},
  }

  -- First pass:
  -- apply monitor rules, expand sets, and count repeated naming keys.
  for _, group in ipairs(groups) do
    hl.monitor(monitor_rule(group))

    local group_ws = merge(defaults, group.workspaces or {})
    local slots, count = expand_sets(group_ws.sets)

    for slot = 1, count do
      local set = slots[slot] or {}
      local ws = merge(group_ws, set)

      local label = ws.label or ""
      local set_label = ws.set_label or ""
      local key = label .. "\0" .. set_label

      key_totals[key] = (key_totals[key] or 0) + 1

      table.insert(planned, {
        id = next_id,
        slot = slot,
        output = group.output,
        ws = ws,
        label = label,
        set_label = set_label,
        key = key,
      })

      next_id = next_id + 1
    end
  end

  -- Second pass:
  -- render names and apply workspace rules.
  for _, item in ipairs(planned) do
    local ws = item.ws
    local repeated = key_totals[item.key] > 1

    key_ids[item.key] = (key_ids[item.key] or 0) + 1

    local set_id = ""
    if repeated then
      set_id = key_ids[item.key]
    end

    local values = {
      prefix = ws.prefix or "",
      label = item.label,
      set_label = item.set_label,
      set_id = set_id,
      suffix = ws.suffix or "",
      slot = item.slot,
      id = item.id,
      output = item.output or "",
    }

    local name = render(
      pick_format(ws.format, repeated),
      values
    )

    -- If no label/set_label/format produced a name, use the ID.
    -- This is not a default workspace label; it is a safety fallback.
    if name == "" then
      name = tostring(item.id)
    end

    -- Last-resort safeguard only.
    if used_names[name] then
      name = name .. "[" .. tostring(item.id) .. "]"
    end

    used_names[name] = true

    local rule = {
      workspace = tostring(item.id),
      monitor = item.output,
      default = item.slot == 1,
      default_name = name,
      layout = ws.layout,
      persistent = ws.persistent or false,
    }

    if ws.layout_opts then
      rule.layout_opts = ws.layout_opts
    end

    hl.workspace_rule(rule)

    table.insert(model.ids, item.id)

    model.by_id[item.id] = {
      id = item.id,
      name = name,
      label = item.label,
      set_label = item.set_label,
      set_id = set_id,
      slot = item.slot,
      monitor = item.output,
      layout = ws.layout,
    }

    model.by_name[name] = model.by_id[item.id]
  end

  return model
end

return M