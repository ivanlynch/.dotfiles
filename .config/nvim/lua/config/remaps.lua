local set = vim.keymap.set
local opts = { noremap = true, silent = true }

set("n", "J", ":move -2<CR>", opts)
set("n", "K", ":move +1<CR>", opts)
