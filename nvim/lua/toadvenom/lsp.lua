-- lsp with no plugins. 0.12 has vim.lsp.config built in, so the server
-- tables are written out here. the servers come from nix (packages.nix)

vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git" },
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            -- match stylua: spaces, no `=` alignment
            format = {
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "4",
                    align_continuous_assign_statement = "false",
                },
            },
        },
    },
})

vim.lsp.config("clangd", {
    cmd = { "clangd", "--background-index" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_markers = { "compile_commands.json", ".clangd", ".git" },
})

vim.lsp.config("texlab", {
    cmd = { "texlab" },
    filetypes = { "tex", "plaintex", "bib" },
    root_markers = { ".latexmkrc", ".git" },
})

-- html, css, json: vscode-langservers-extracted. js: typescript-language-server
vim.lsp.config("html", {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    root_markers = { "package.json", ".git" },
    init_options = {
        provideFormatter = true,
        -- <style> and <script> get the css/js halves
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { "html", "css", "javascript" },
    },
})

vim.lsp.config("cssls", {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
    settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
    },
})

vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { "package.json", ".git" },
    init_options = { provideFormatter = true },
})

vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

-- only servers on PATH, so a pending rebuild doesn't throw on open
local enabled = {}
for _, name in ipairs({ "lua_ls", "clangd", "texlab", "html", "cssls", "jsonls", "ts_ls" }) do
    if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
        table.insert(enabled, name)
    end
end
vim.lsp.enable(enabled)

-- completion: popup puts docs beside the menu, fuzzy keeps filtering
vim.o.completeopt = "menu,menuone,popup,noselect,fuzzy"
vim.opt.shortmess:append("c") -- no "match 1 of 4" spam

local function pum(key, fallback)
    return function()
        return vim.fn.pumvisible() == 1 and key or fallback
    end
end

vim.keymap.set("i", "<Tab>", pum("<C-n>", "<Tab>"), { expr = true })
vim.keymap.set("i", "<S-Tab>", pum("<C-p>", "<S-Tab>"), { expr = true })
-- confirm only when something is picked
vim.keymap.set("i", "<Cr>", function()
    return vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<Cr>"
end, { expr = true })
-- ask anywhere, not just after a trigger character
vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get)

local format = vim.api.nvim_create_augroup("UserLspFormat", {})
local words = vim.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", "")

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLsp", {}),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        if client:supports_method("textDocument/completion") then
            -- servers only trigger on punctuation, so add every letter.
            -- once per client: LspAttach fires again for each new buffer
            local provider = client.server_capabilities.completionProvider
            if provider and not provider.toad_words then
                provider.triggerCharacters = vim.list_extend(provider.triggerCharacters or {}, words)
                provider.toad_words = true
            end

            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end

        -- format on save where the server can. cleared first so a restart
        -- or a second server doesn't stack another one
        if client:supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = format, buffer = ev.buf })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = format,
                buffer = ev.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})

-- 0.12 already maps K, grn, gra, grr, gri. =ap formats by hand
vim.keymap.set("n", "=ap", function()
    vim.lsp.buf.format({ timeout_ms = 1000 })
end)

-- diagnostics in a float on hover, not virtual text
vim.diagnostic.config({
    virtual_text = false,
    float = { border = "rounded" },
})

vim.api.nvim_create_autocmd("CursorHold", {
    group = vim.api.nvim_create_augroup("UserDiagnosticFloat", {}),
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})
