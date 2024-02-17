vim.g.mapleader = ";"
vim.g.tpipeline_autoembed = 0
vim.g.tpipeline_satusline = "%!tpipeline#stl#line()"

local config = {
	scrolloff = 8, -- Scroll offset
	number = true, -- Show line numbers
	relativenumber = true, -- Show relative line numbers
	tabstop = 4, -- Number of spaces that a <Tab> in the file counts for
	softtabstop = 4, -- Number of spaces that a <Tab> counts for while editing
	shiftwidth = 4, -- Number of spaces to use for each step of (auto)indent
	expandtab = true, -- Use spaces instead of tabs
	smartindent = true, -- Do smart autoindenting when starting a new line
	clipboard = "unnamedplus", -- Use the system clipboard
	errorbells = false, -- No error bells
	cmdheight = 1, -- Height of the command bar
	timeout = true, -- Enable timeout
	timeoutlen = 300, -- Time to wait for a mapped sequence to complete
}

for k, v in pairs(config) do
	vim.opt[k] = v
end
