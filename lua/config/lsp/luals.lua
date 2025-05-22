local capabilities = require('cmp_nvim_lsp').default_capabilities();

vim.lsp.config['luals'] = {
	capabilities = capabilities,
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			}
		}
	}
}
