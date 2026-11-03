local M = {}

-- `pin` only takes floating windows, so pinning floats the window first and
-- unpinning tiles it again. On the 4K panel a pinned window gets a centred
-- 16:10 frame (40% x 45% of the panel), since the tile size it would keep has
-- no set shape.
function M.toggle_pin()
    local w = hl.get_active_window()
    if not w then
        return
    end

    if w.pinned then
        hl.dispatch(hl.dsp.window.pin({ action = "disable" }))
        hl.dispatch(hl.dsp.window.float({ action = "disable" }))
        return
    end

    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.pin({ action = "enable" }))
    local m = hl.get_active_workspace().monitor
    if m and m.name == "HDMI-A-1" then
        hl.dispatch(hl.dsp.window.resize({ x = math.floor(m.width * 0.4), y = math.floor(m.height * 0.45) }))
        hl.dispatch(hl.dsp.window.center())
    end
end

-- Focuses the notes vault on its own panel, so the main panel keeps its
-- workspace; starts Obsidian first when it is not running.
function M.focus_notes()
    for _, w in ipairs(hl.get_windows()) do
        if w.class == "md.obsidian.Obsidian" then
            hl.dispatch(hl.dsp.focus({ window = w }))
            return
        end
    end
    hl.exec_cmd("obsidian")
end

return M
