return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local config = {
			formatters = {
				prettier = {
					args = function(self, ctx)
						if vim.endswith(ctx.filename, ".md") then
							return {
								"prettier",
								"--parser",
								"markdown",
								"--require-pragma",
							}
						end
					end,
				},
			},
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				markdown = { "prettier" },
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

		conform.setup(config)
		conform.format({ async = true, lsp_fallback = true })
	end,
}
