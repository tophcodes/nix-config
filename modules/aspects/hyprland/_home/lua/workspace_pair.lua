-- Workspace N is a pair: N on HDMI-A-1 and N+10 on DP-3 (the workspace rules
-- in settings.nix bind them). Pairs run from 1 to 8.
local M = {}

-- Offset of each panel's half of a pair.
local offset = { ["HDMI-A-1"] = 0, ["DP-3"] = 10 }

-- `n` is a pair number, or "next"/"prev" relative to the focused workspace,
-- wrapping from 8 to 1 and back.
local function resolve(n)
    local current = hl.get_active_workspace().id % 10
    if n == "next" then
        return current % 8 + 1
    elseif n == "prev" then
        return (current + 6) % 8 + 1
    end
    return n
end

-- Flips every connected panel to its half of pair `n`. The focused panel goes
-- last so it keeps focus. Focusing a monitor warps the cursor, so the cursor
-- is put back afterwards.
function M.switch(n)
    n = resolve(n)
    local focused = hl.get_active_monitor()
    local cursor = hl.get_cursor_pos()

    local order = {}
    for _, m in ipairs(hl.get_monitors()) do
        if offset[m.name] and m.name ~= focused.name then
            table.insert(order, m.name)
        end
    end
    if offset[focused.name] then
        table.insert(order, focused.name)
    end

    for _, name in ipairs(order) do
        hl.dispatch(hl.dsp.focus({ monitor = name }))
        hl.dispatch(hl.dsp.focus({ workspace = n + offset[name] }))
    end
    if cursor then
        hl.dispatch(hl.dsp.cursor.move({ x = cursor.x, y = cursor.y }))
    end
end

-- Sends the active window to pair `n`'s half on the focused panel and keeps
-- focus where it is.
function M.move(n)
    n = resolve(n)
    local name = hl.get_active_monitor().name
    hl.dispatch(hl.dsp.window.move({ workspace = n + (offset[name] or 0), follow = false }))
end

return M
