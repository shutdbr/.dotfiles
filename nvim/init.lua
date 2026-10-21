-- byte-compile cache for lua modules, roughly halves startup
vim.loader.enable()

require("toadvenom.set")
require("toadvenom.remap")
require("toadvenom.plugins")
require("toadvenom.lsp")
