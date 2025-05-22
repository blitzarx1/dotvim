require('config.commands.FuzzyFiles')
require('config.commands.ProjectSearch')

local g     = vim.g
g.mapleader = " "

local map   = vim.keymap.set
local opts  = { noremap = true, silent = true }

-- window nav
map('n', '<C-h>', '<cmd>wincmd h<CR>', opts)
map('n', '<C-j>', '<cmd>wincmd j<CR>', opts)
map('n', '<C-k>', '<cmd>wincmd k<CR>', opts)
map('n', '<C-l>', '<cmd>wincmd l<CR>', opts)

map('n', '<leader>f', function()
  local entry = vim.fn.input('pattern: ')
  if entry ~= '' then FuzzyFiles(entry) end
end, {
  noremap = true,
  silent = true,
  desc   = 'fuzzy find files → quickfix',
})

-- lsp
map('n', 'gr', vim.lsp.buf.references, opts)
map('n', 'gd', vim.lsp.buf.definition, opts)
map('n', 'gi', vim.lsp.buf.implementation, opts)
map('n', '<leader>k', vim.lsp.buf.hover, opts)

vim.keymap.set("n", "<leader>/", "<cmd>ProjectSearch<cr>", { desc = "Project grep into quickfix" })

