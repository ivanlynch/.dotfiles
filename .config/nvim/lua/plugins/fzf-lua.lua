
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  keys = {
    {
      "<leader>ff",
      function()
        require('fzf-lua').files()
      end,
      desc="[F]ind [F]iles"
    },
    {
      "<leader>fg",
      function()
        require('fzf-lua').live_grep()
      end,
      desc="[F]ind using [G]rep"
    },
    {
      "<leader>fb",
      function()
        require('fzf-lua').buffers()
      end,
      desc="[F]ind [B]uffers"
    },
    {
      "<leader>fh",
      function()
        require('fzf-lua').oldfiles()
      end,
      desc="[F]ind [H]istory"
    },
    {
      "<leader>fk",
      function()
        require('fzf-lua').keymaps()
      end,
      desc="[F]ind [K]eymappings"
    },
  }
}
