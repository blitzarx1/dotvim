-- basic
require('config.options')
require('config.remaps')

-- commands
require('config.commands.Fmt')
require('config.commands.FuzzyFiles')
require('config.commands.ProjectSearch')

-- lsp
require('config.lsp')

-- colorscheme
require('config.color')

-- other plugins
require('config.treesitter')
require('config.gitsigns')
require('config.cmp')

