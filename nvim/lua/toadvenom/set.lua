local set = vim.opt

set.nu = true
set.relativenumber = true

set.tabstop = 4
set.softtabstop = 4

set.shiftwidth = 4
set.expandtab = true

set.smartindent = true
set.guicursor = ""
set.signcolumn = "yes"

set.swapfile = false
set.undofile = true
set.clipboard:append("unnamedplus")

set.hlsearch = false
set.inccommand = "split"
set.ignorecase = true

set.termguicolors = true

set.scrolloff = 999

set.isfname:append("@-@")
-- also the diagnostic float delay (lsp.lua)
set.updatetime = 950

set.splitbelow = true
set.splitright = true

-- `:find <Tab>` as the picker. slow if you :cd somewhere huge
set.path:append("**")
set.wildoptions = "fuzzy,pum,tagfile"

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("UserYank", {}),
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

set.virtualedit = "block"

-- built-in treesitter where 0.12 ships a parser, regex elsewhere
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitter", {}),
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})
