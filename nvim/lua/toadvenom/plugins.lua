-- plugins via vim.pack, pinned in nvim-pack-lock.json.
-- update: :lua vim.pack.update(), :w to accept, then commit the lock

local ok, err = pcall(vim.pack.add, {
    "https://github.com/ellisonleao/gruvbox.nvim",
    "https://github.com/stevearc/oil.nvim",
})
if not ok then
    -- offline first start: carry on without them
    vim.api.nvim_echo({ { "could not install plugins:\n" .. tostring(err), "ErrorMsg" } }, true, {})
    return
end

require("gruvbox").setup({
    undercurl = false,
    underline = false,
    -- no italics anywhere
    italic = {
        strings = false,
        emphasis = false,
        comments = false,
        folds = false,
    },
    invert_selection = true,
    invert_tabline = true,
    contrast = "hard",
    -- gruvbox browns, bubblegum accents
    palette_overrides = {
        bright_red = "#ed286f",    -- base08
        bright_green = "#08c7a4",  -- base0B
        bright_blue = "#00a2b8",   -- base0D
        bright_purple = "#f030a8", -- base0E
        bright_aqua = "#00b9a3",   -- base0C
    },
    transparent_mode = true,
})
vim.cmd("colorscheme gruvbox")

-- oil: edit a directory like a buffer. `-` goes up, :w applies
require("oil").setup({
    columns = {}, -- no icons, no devicons
    view_options = { show_hidden = true },
})
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "open parent directory" })
