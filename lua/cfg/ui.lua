local function width_on_editor(pct, min_w, max_w)
    local editor_w = vim.o.columns
    local result = math.floor(editor_w * pct)
    if max_w then
        result = vim.fn.min({ max_w, result })
    end
    if min_w then
        result = vim.fn.max({ min_w, result })
    end
    return result
end

local function height_on_editor(pct, min_h, max_h)
    local editor_h = vim.o.lines
    local result = math.floor(editor_h * pct)
    if max_h then
        result = vim.fn.min({ max_h, result })
    end
    if min_h then
        result = vim.fn.max({ min_h, result })
    end
    return result
end

local M = {
    width_on_editor = width_on_editor,
    height_on_editor = height_on_editor,
}

return M