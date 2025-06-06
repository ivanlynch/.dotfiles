vim.lsp.config['html'] = {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },
  settings = {
    html = {
      format = {
        enable = true,
      }
    }
  }
}

vim.lsp.config['css'] = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css' },
  root_markers = { 'package.json', '.git' },
  settings = {
    css = {
      format = {
        enable = true,
      }
    }
  }
}

-- typescript-language-server
vim.lsp.config['ts'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { 'package.json', '.git' },
  settings = {
    typescript = {
      format = {
        enable = true,
      }
    }
  }
}

vim.lsp.config['markdown'] = {
  cmd = { 'vscode-markdown-language-server', '--stdio' },
  filetypes = { 'markdown' },
  root_markers = { 'package.json', '.git' },
  settings = {
    markdown = {
      requireConfig = false 
    }
  }
}

vim.lsp.enable('html')
vim.lsp.enable('css')
vim.lsp.enable('ts')
vim.lsp.enable('markdown')
