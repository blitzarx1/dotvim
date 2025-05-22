function LSPFmt()
	vim.lsp.buf.format()
end

vim.api.nvim_create_user_command('Fmt', LSPFmt, {})
