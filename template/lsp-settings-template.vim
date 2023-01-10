lua<<EOF
    local lspconfig = require('lspconfig')
    local mason_lspconfig=require("mason-lspconfig")
    local null_ls = require("null-ls")
    local mason_null_ls = require("mason-null-ls")

    -- {{
    -- To add new LSP server for language, you need to define possibly 4 components in below configurations:
    --
    -- LSP server configurations
    --
    -- Key:
    --      Language, ensure this field is unique. Notice this field is just a hint, not actually been used.
    -- Value:
    --      1. mason-lspconfig ensure installed server name, set 'nil' if not used.
    --      2. lspconfig setup configuration, set '{}' by default.
    --      3. (optional) null-ls formatters, set 'nil' if not used.
    --      4. (optional) null-ls setup configuration, set 'nil' if not used.
    local lsp_servers = {
        protobuf = {"bufls", {}, nil, nil},
        c = {"clangd", {}, nil, nil},
        cmake = {"cmake", {}, nil, nil},
        css = {"cssls", {}, nil, nil},
        cssmodules = {"cssmodules_ls", {}, nil, nil},
        eslint = {"eslint", {}, {"eslint"}, {null_ls.builtins.code_actions.eslint}},
        go = {"gopls", {}, nil, nil},
        grammar = {"grammarly", {}, nil, nil},
        graphql = {"graphql", {}, nil, nil},
        html = {"html", {}, nil, nil},
        xml = {"lemminx", {}, nil, nil},
        json = {"jsonls", {}, nil, nil},
        javascript = {"tsserver", {}, nil, nil},
        lua = {"sumneko_lua", {}, nil, nil},
        markdown = {"marksman", {}, nil, nil},
        -- prettierd is not a LSP server in mason, but we use it as a powerful formatter for js/ts/md/json/html/etc.
        prettier = {nil, {}, {"prettierd"}, {null_ls.builtins.formatting.prettierd}},
        -- pyright does not provide formatting, so we add black/isort to null-ls, as python formatter.
        python = {"pyright", {}, {"black", "isort"}, {null_ls.builtins.formatting.black, null_ls.builtins.formatting.isort}},
        rust = {"rust_analyzer", {}, nil, nil},
        sql = {"sqlls", {}, nil, nil},
        toml = {"taplo", {}, nil, nil},
        yaml = {"yamlls", {}, nil, nil},
        vim = {"vimls", {}, nil, nil},
    }
    if vim.fn.has('win32') then
        -- powershell for windows
        lsp_servers.powershell = {"powershell_es", {}, nil, nil}
    else
        -- bash for UNIX/Linux/macOS
        lsp_servers.bash = {"bashls", {}, {"shfmt"}, {null_ls.builtins.formatting.shfmt}}
    end
    -- }}


    -- {{
    -- The real setup work goes here.

    -- Setup mason-lspconfig
    local mason_lspconfig_ensure_installed = {}
    for lang, conf in pairs(lsp_servers) do
        if conf[1] ~= nil then
            table.insert(mason_lspconfig_ensure_installed, conf[1])
        end
    end
    mason_lspconfig.setup {
        ensure_installed = mason_lspconfig_ensure_installed,
    }

    -- Setup lspconfig
    for lang, conf in pairs(lsp_servers) do
        if conf[1] ~= nil then
            lspconfig[conf[1]].setup(conf[2])
        end
    end

    -- Setup null-ls
    local null_ls_sources = {}
    for lang, conf in pairs(lsp_servers) do
        if conf[4] ~= nil then
            for index, builtin in ipairs(conf[4]) do
                table.insert(null_ls_sources, builtin)
            end
        end
    end
    null_ls.setup({
        sources = null_ls_sources,
    })

    -- Setup mason-null-ls
    local mason_null_ls_ensure_installed = {}
    for lang, conf in pairs(lsp_servers) do
        if conf[3] ~= nil then
            for index, formatter in ipairs(conf[3]) do
                table.insert(mason_null_ls_ensure_installed, formatter)
            end
        end
    end
    mason_null_ls.setup({
        ensure_installed = mason_null_ls_ensure_installed,
    })

    -- }}
EOF
