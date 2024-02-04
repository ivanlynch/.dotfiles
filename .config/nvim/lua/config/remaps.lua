local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>e", ":Vex<CR>", opts)
keymap.set("n", "<leader>wh", "<C-w>h", opts)
keymap.set("n", "<leader>wj", "<C-w>j", opts)
keymap.set("n", "<leader>wk", "<C-w>k", opts)
keymap.set("n", "<leader>wl", "<C-w>l", opts)

keymap.set("n", "J", ":move -2<CR>", opts)
keymap.set("n", "K", ":move +1<CR>", opts)












