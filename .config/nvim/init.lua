vim.opt.swapfile = false
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.lsp.enable('html')
vim.lsp.enable('css')
vim.lsp.enable('typescript')
vim.lsp.enable('markdown')

vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'noselect' }

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client_id = vim.tbl_get(event, 'data', 'client_id')
    if client_id then
      vim.lsp.completion.enable(true, client_id, event.buf, { autotrigger = false })
    end
  end
})


require("config.lazy")
