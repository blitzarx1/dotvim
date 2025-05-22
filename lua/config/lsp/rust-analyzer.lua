local capabilities = require('cmp_nvim_lsp').default_capabilities();

vim.lsp.config["rust-analyzer"] = {
	capabilities = capabilities,
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
}
