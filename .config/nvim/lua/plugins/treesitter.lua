return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSInstall",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "dockerfile",
          "css",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "rust",
          "toml",
          "typescript",
          "yaml",
        },
        sync_install = true,
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  }
}
