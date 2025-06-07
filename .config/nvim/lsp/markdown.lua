return {
    cmd = { 'vscode-markdown-language-server', '--stdio' },
    filetypes = { 'markdown' },
    root_markers = { 'package.json', '.git' },
    settings = {
        markdown = {
            requireConfig = false
        }
    }
}
