local o = vim.o

o.syntax = "enable"

o.list = true
o.listchars = "tab:▸ ,space:·,trail:·,extends:›,precedes:‹,eol:$"
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
	-- non-text chars
    vim.api.nvim_set_hl(0, "NonText",   { fg = "#404040", bg = "NONE" })

	-- selection
	local bg = "#eb6f92"
	local fg = "#ffffff"
	vim.api.nvim_set_hl(0, "Visual",   { bg = bg, fg = fg })
	vim.api.nvim_set_hl(0, "VisualNOS",{ bg = bg, fg = fg })
  end,
})

-- colorscheme
require("rose-pine").setup({
  styles = {
    italic = false,
  },
})

vim.cmd("colorscheme rose-pine-moon")

