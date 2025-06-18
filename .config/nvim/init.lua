local o = vim.opt

o.termguicolors = true -- Enable true colors
o.background = "dark" -- set dark mode
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.clipboard = "unnamedplus" -- When yank copy to clipboard also
o.swapfile = false
o.number = true -- active line numbers
o.relativenumber = true -- use relative numbers from current line
o.cmdheight = 0 -- Status bar position. 0 means the first line from bottom to top
o.cursorline = true -- Highlight cursor line

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

o.completeopt = { "menu", "menuone", "noinsert", "noselect" }

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client_id = vim.tbl_get(event, "data", "client_id")
		if client_id then
			vim.lsp.completion.enable(true, client_id, event.buf, { autotrigger = false })
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

require("core.lazy")
require("core.lsp")
