-- ---- Const ----

local OS = vim.loop.os_uname().sysname
local editor_width = require("cfg.ui").editor_width
local editor_height = require("cfg.ui").editor_height

local M = {
    os = {
        name = OS,
        is_macos = OS == "Darwin",
        is_windows = vim.fn.has("win32") > 0,
    },
    lsp = {
        diagnostics = {
            signs = {
                ["error"] = "", -- nf-fa-times \uf00d
                ["warning"] = "", -- nf-fa-warning \uf071
                ["info"] = "", -- nf-fa-info_circle \uf05a
                -- ["hint"] = "", -- nf-mdi-lightbulb \uf834, used for codeAction in vscode, choose another icon
                ["hint"] = "", -- : nf-fa-flag \uf024,  nf-fa-bell \uf0f3
                ["ok"] = "", -- nf-fa-check \uf00c
            },
        },
    },
    ui = {
        border = "rounded", -- border options: single,double,rounded,solid,shadow
        layout = {
            width = editor_width(0.9, 10, nil),
            height = editor_height(0.8, 5, nil),
        },
    },
    perf = {
        -- performance
        file = {
            maxsize = 1024 * 1024 * 5, -- 5MB
        },
    },
}

return M