return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	dependencies = {
		"echasnovski/mini.icons",
	},
	config = function()
		require("which-key").setup({})
		local wk = require("which-key")
		wk.register({
			{ '<leader>c', group = "Code Actions" },
			{ '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', desc = "Show code actions" },
			{ '<leader>cd', '<cmd>Telescope lsp_definitions<cr>', desc = "Go to the definition" },
			{ '<leader>cg', '<cmd>TSC<cr>', desc = "Show global problems" },
			{ '<leader>ci', '<cmd>Telescope lsp_implementations<cr>', desc = "Go to the implementation" },
			{ '<leader>cp', '<cmd>TroubleToggle<cr>', desc = "Show problems" },
			{ '<leader>cr', '<cmd>Telescope lsp_references show_line=false<cr>', desc = "Show references" },

			{ '<leader>f', group = "File Actions" },
			{ '<leader>fS', '<cmd>Telescope lsp_workspace_symbols<cr>', desc = "Workspace Symbols" },
			{ '<leader>fb', '<cmd>Telescope buffers<cr>', desc = "Buffers" },
			{ '<leader>ff', '<cmd>Telescope find_files<cr>', desc = "Find File" },
			{ '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = "Grep" },
			{ '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = "Help Tags" },
			{ '<leader>fp', '<cmd>Telescope project<cr>', desc = "Project" },
			{ '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = "Recent Files" },
			{ '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', desc = "Document Symbols" },

			{ '<leader>g', group = "Git Actions" },
			{ '<leader>gC', '<cmd>Telescope git_commits<cr>', desc = "Show all commits" },
			{ '<leader>gb', '<cmd>Telescope git_branches<cr>', desc = "Show branches" },
			{ '<leader>gc', '<cmd>Telescope git_bcommits<cr>', desc = "Show current file commits" },
			{ '<leader>gs', '<cmd>Telescope git_status<cr>', desc = "Show status" },
			{ '<leader>gt', '<cmd>Telescope git_stash<cr>', desc = "Show stash" },

			{ '<leader>w', group = "Window Actions" },
			{ '<leader>wh', '<C-w>h', desc = "Move Left" },
			{ '<leader>wj', '<C-w>j', desc = "Move Down" },
			{ '<leader>wk', '<C-w>k', desc = "Move Up" },
			{ '<leader>wl', '<C-w>l', desc = "Move Right" },
			{ '<leader>wv', '<C-w>v', desc = "Split Vertical" },
			{ '<leader>ws', '<C-w>s', desc = "Split Horizontal" },
		}, { mode = "n" })
	end,
}
