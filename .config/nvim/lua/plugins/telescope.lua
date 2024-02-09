return {
	"nvim-telescope/telescope.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		"nvim-telescope/telescope-project.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	opts = {
		defaults = {
			layout_config = {
				horizontal = {
					preview_cutoff = 0,
				},
			},
			wrap_results = true,
		},
		pickers = {
			find_files = {
				hidden = true,
			},
			diagnostics = {
				previewer = false,
			},
		},
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
			project = {
				base_dirs = {
					"~/dev",
				},
				theme = "dropdown",
				order_by = "asc",
				on_project_selected = function(prompt_bufnr)
					require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr, true)
				end,
			},
		},
	},
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		telescope.load_extension("fzf")
		telescope.load_extension("file_browser")
		telescope.load_extension("ui-select")
	end,
	keys = {
		{
			"<leader>f",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>b",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find()
			end,
			desc = "Find current buffer",
		},
		{
			"<leader>lg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Live Grep",
		},
		{
			"<leader>a",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>gf",
			function()
				require("telescope.builtin").git_files({ show_untracked = true })
			end,
			desc = "Git files",
		},
		{
			"<leader>gs",
			function()
				require("telescope.builtin").git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>ggc",
			function()
				require("telescope.builtin").git_commits()
			end,
			desc = "Git Global Commits",
		},
		{
			"<leader>gc",
			function()
				require("telescope.builtin").git_bcommits()
			end,
			desc = "Git Commits",
		},
		{
			"<leader>gb",
			function()
				require("telescope.builtin").git_branches()
			end,
			desc = "Git Commits",
		},
		{
			"<leader>gr",
			function()
				require("telescope.builtin").lsp_references()
			end,
			desc = "Git Commits",
		},
		{
			"<leader>p",
			function()
				require("telescope").extensions.project.project()
			end,
			desc = "Projects Browser",
		},
		{
			"<leader>l",
			function()
				require("telescope.builtin").jumplist()
			end,
			desc = "File Browser",
		},
		{
			"<leader>imp",
			function()
				require("telescope.builtin").lsp_implementations()
			end,
			desc = "File Browser",
		},
		{
			"<leader>ds",
			function()
				require("telescope.builtin").diagnostics({ bufnr = 0 })
			end,
			desc = "Diagnostics",
		},
	},
}
