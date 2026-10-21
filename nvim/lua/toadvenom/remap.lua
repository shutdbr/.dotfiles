local remap = vim.keymap.set

vim.g.mapleader = " "

-- x, not v: v also covers select mode, where snippet placeholders take typing
remap("x", "K", ":m '<-2<CR>gv=gv")
remap("x", "J", ":m '>+1<CR>gv=gv")
remap("i", "jj", "<Esc>")

remap("n", "<leader>bo", function()
    local current = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.bo[buf].buflisted and not vim.bo[buf].modified then
            vim.api.nvim_buf_delete(buf, {})
        end
    end
end, { desc = "close other saved buffers" })

-- files. `-` opens oil (plugins.lua)
remap("n", "<leader>ff", ":find ", { desc = "find file below cwd" })
remap("n", "<leader>fb", ":buffer ", { desc = "switch buffer" })

-- movement, kept centred
remap("n", "<C-k>", "<C-u>zz")
remap("n", "<C-j>", "<C-d>zz")
remap("n", "n", "nzzzv")
remap("n", "N", "Nzzzv")

remap("n", "Y", "y$")
remap("n", "J", "mzJ`z")
remap("n", "H", "0i<Cr><Esc>k")
-- built-in [<Space>: O would carry the comment leader onto the blank line
remap("n", "L", "[<Space>", { remap = true })

-- quotes: q is ", Q is '
remap("n", "ciq", 'ci"')
remap("n", "ciQ", "ci'")
remap("n", "cinq", '0f";;lci"')
remap("n", "viq", 'vi"')
remap("n", "viQ", "vi'")
remap("n", "yiq", 'yi"')
remap("n", "yiQ", "yi'")

-- brackets
remap("n", "cic", "0f{lci{")
remap("n", "cis", "ci[")

-- delete without clobbering the register
remap("x", "<leader>p", '"_dP')
remap("x", "x", '"_x')

remap("n", "<leader>sn", "<cmd>set invnumber<cr>", { silent = true })
remap("n", "<leader>srn", "<cmd>set invnumber invrelativenumber<cr>", { silent = true })
remap("n", "<leader>sc", function()
    vim.o.signcolumn = vim.o.signcolumn == "no" and "yes" or "no"
end, { desc = "toggle the sign column" })

-- replace the word under the cursor everywhere
remap("n", "<leader>hw", ":%s/\\<<C-r><C-w>\\>")

-- splits: left/right is width, up/down is height
remap("n", "<C-left>", "<cmd>vertical resize -5<cr>")
remap("n", "<C-right>", "<cmd>vertical resize +5<cr>")
remap("n", "<C-down>", "<cmd>resize -5<cr>")
remap("n", "<C-up>", "<cmd>resize +5<cr>")

-- no quit mapping: ZZ and ZQ already do it, and an <Esc> prefix stalls every esc
