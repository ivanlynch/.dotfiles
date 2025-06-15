## My Config

This repo was created to share my config and to be plug and play when i switch computer. The goal is to have one command config for my daily workflow.

### To install my config just run:

#### Linux / macOS

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ivanlynch/.dotfiles/main/bin/dotfiles)"
```

### Plugins

1. Treesitter
   This plugins installs all the needed parsers

2. Mason
   Mason is a neovim dependencies manager. Needed to install LSPs and Formatters

3. Conform
   Conform is a formatter configuration for every file. Where we connect mason formatters with files.

4. Mason Conform
   Is a plugin that reads the configuration defined in conform and automatically installs whatever it needs from Mason.

5. fzf-lua
