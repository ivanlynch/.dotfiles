return {
	"coffebar/neovim-project",
	opts = {
		projects = { -- define project roots
			"~/dev/*",
			"~/.config/*",
		},
		picker = {
			type = "fzf-lua",
		},
	},
	init = function()
		vim.opt.sessionoptions:append("globals")
	end,
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "ibhagwan/fzf-lua" },
		{ "Shatur/neovim-session-manager" },
	},
	lazy = false,
	priority = 100,
  keys = {
    {
      "<leader>fp",
      "<cmd>NeovimProjectDiscover<CR>",
      desc="[F]ind [P]rojects",
      mode="n"
    },
  }
}
