local FD = vim.fn.executable("fdfind") > 0 and "fdfind" or "fd"
local BAT = vim.fn.executable("batcat") > 0 and "batcat" or "bat"

local FILES_CMD = FD
    .. " . --color=never --type f --type symlink --follow --ignore-case"
local GREP_CMD =
    "rg --column --line-number --no-heading --color=always --case-sensitive"

local M = {
    FD = FD,
    BAT = BAT,
    FILES_CMD = FILES_CMD,
    GREP_CMD = GREP_CMD,
}

return M