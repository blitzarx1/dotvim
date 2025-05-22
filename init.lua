local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug('rose-pine/neovim')

Plug('williamboman/mason.nvim')

Plug('nvim-treesitter/nvim-treesitter')

-- git
Plug('tpope/vim-fugitive')
Plug('lewis6991/gitsigns.nvim')

-- autocomplete
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

vim.call('plug#end')

require("config")

