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
			cache_picker = { num_pickers = 10 },
			dynamic_preview_title = true,
			layout_strategy = "vertical",
			layout_config = { vertical = { width = 0.9, height = 0.9, preview_height = 0.6, preview_cutoff = 0 } },
			path_display = { "smart", shorten = { len = 3 } },
			wrap_results = true,
		},
		pickers = {
			find_files = {
				hidden = true,
			},
			diagnostics = {
				previewer = false,
			},
			current_buffer_tags = { fname_width = 100 },
			jumplist = { fname_width = 100 },
			loclist = { fname_width = 100 },
			lsp_definitions = { fname_width = 100 },
			lsp_document_symbols = { fname_width = 100 },
			lsp_dynamic_workspace_symbols = { fname_width = 100 },
			lsp_implementations = { fname_width = 100 },
			lsp_incoming_calls = { fname_width = 100 },
			lsp_outgoing_calls = { fname_width = 100 },
			lsp_references = { fname_width = 100 },
			lsp_type_definitions = { fname_width = 100 },
			lsp_workspace_symbols = { fname_width = 100 },
			quickfix = { fname_width = 100 },
			tags = { fname_width = 100 },
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
}
