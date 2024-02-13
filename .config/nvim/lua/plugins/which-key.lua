return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local opts = {}
		local mappings = {
			c = {
				name = "Code Actions",
				p = { "<cmd>TroubleToggle<cr>", "Show problems" },
				i = { "<cmd>Telescope lsp_implementations<cr>", "Go to the implementation" },
				d = { "<cmd>Telescope lsp_definitions<cr>", "Go to the definition" },
				r = { "<cmd>Telescope lsp_references show_line=false<cr>", "Show references" },
				a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Show code actions" },
				g = { "<cmd>TSC<cr>", "Show global problems" },
			},
			f = {
				name = "File Actions",
				f = { "<cmd>Telescope find_files<cr>", "Find File" },
				r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
				g = { "<cmd>Telescope live_grep<cr>", "Grep" },
				b = { "<cmd>Telescope buffers<cr>", "Buffers" },
				h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
				s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
				S = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols" },
				p = { "<cmd>Telescope project<cr>", "Project" },
			},
			w = {
				name = "Window Actions",
				v = { "<C-w>v", "Split Vertical" },
				s = { "<C-w>s", "Split Horizontal" },
				h = { "<C-w>h", "Move Left" },
				j = { "<C-w>j", "Move Down" },
				k = { "<C-w>k", "Move Up" },
				l = { "<C-w>l", "Move Right" },
			},
			g = {
				name = "Git Actions",
				C = { "<cmd>Telescope git_commits<cr>", "Show all commits" },
				c = { "<cmd>Telescope git_bcommits<cr>", "Show current file commits" },
				b = { "<cmd>Telescope git_branches<cr>", "Show branches" },
				s = { "<cmd>Telescope git_status<cr>", "Show status" },
				t = { "<cmd>Telescope git_stash<cr>", "Show stash" },
			},
		}
		require("which-key").setup(opts)
		require("which-key").register(mappings, { prefix = "<leader>" })
	end,
}
