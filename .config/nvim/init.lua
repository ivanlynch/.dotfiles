vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.swapfile = false
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

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
