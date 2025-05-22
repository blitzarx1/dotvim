function ProjectSearch()
  local pattern = vim.fn.input("grep pattern: ")
  if pattern == "" then return end

  vim.cmd("silent grep " .. vim.fn.shellescape(pattern) .. " ./")

  if #vim.fn.getqflist() > 0 then
    vim.cmd("copen")
	vim.fn.clearmatches()
  else
    print("no results")
  end
end

vim.api.nvim_create_user_command("ProjectSearch", function()
  ProjectSearch()
end, { desc = "Grep for pattern in project and open quickfix if results exist" })
