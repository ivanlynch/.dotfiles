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
			["<leader>c"] = { name = "Code Actions" },
			["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Show code actions" },
			["<leader>cd"] = { "<cmd>Telescope lsp_definitions<cr>", "Go to the definition" },
			["<leader>cg"] = { "<cmd>TSC<cr>", "Show global problems" },
			["<leader>ci"] = { "<cmd>Telescope lsp_implementations<cr>", "Go to the implementation" },
			["<leader>cp"] = { "<cmd>TroubleToggle<cr>", "Show problems" },
			["<leader>cr"] = { "<cmd>Telescope lsp_references show_line=false<cr>", "Show references" },

			["<leader>f"] = { name = "File Actions" },
			["<leader>fS"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols" },
			["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "Buffers" },
			["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "Find File" },
			["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "Grep" },
			["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
			["<leader>fp"] = { "<cmd>Telescope project<cr>", "Project" },
			["<leader>fr"] = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
			["<leader>fs"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },

			["<leader>g"] = { name = "Git Actions" },
			["<leader>gC"] = { "<cmd>Telescope git_commits<cr>", "Show all commits" },
			["<leader>gb"] = { "<cmd>Telescope git_branches<cr>", "Show branches" },
			["<leader>gc"] = { "<cmd>Telescope git_bcommits<cr>", "Show current file commits" },
			["<leader>gs"] = { "<cmd>Telescope git_status<cr>", "Show status" },
			["<leader>gt"] = { "<cmd>Telescope git_stash<cr>", "Show stash" },

			["<leader>w"] = { name = "Window Actions" },
			["<leader>wh"] = { "<C-w>h", "Move Left" },
			["<leader>wj"] = { "<C-w>j", "Move Down" },
			["<leader>wk"] = { "<C-w>k", "Move Up" },
			["<leader>wl"] = { "<C-w>l", "Move Right" },
			["<leader>wv"] = { "<C-w>v", "Split Vertical" },
			["<leader>ws"] = { "<C-w>s", "Split Horizontal" },
		})
	end,
}
