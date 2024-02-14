return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local config = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { { "prettierd", "prettier" } },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				markdown = { "prettierd" },
				yaml = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				graphql = { "prettier" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			},
		}

		local options = {
			ft_parsers = {
				--     javascript = "babel",
				--     javascriptreact = "babel",
				--     typescript = "typescript",
				--     typescriptreact = "typescript",
				--     vue = "vue",
				--     css = "css",
				--     scss = "scss",
				--     less = "less",
				--     html = "html",
				--     json = "json",
				--     jsonc = "json",
				--     yaml = "yaml",
				markdown = "markdown",
				["markdown.mdx"] = "mdx",
				--     graphql = "graphql",
				--     handlebars = "glimmer",
			},
			-- Use a specific prettier parser for a file extension
			ext_parsers = {
				-- qmd = "markdown",
			},
		}

		conform.setup(config, options)

		vim.keymap.set({ "n", "v" }, "<C-f>", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "Format file" })
	end,
}
