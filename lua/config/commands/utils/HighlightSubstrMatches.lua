function HighlightSubstrMatches(pattern)
  pattern = vim.fn.escape(pattern, [[\.^$~[]*]])

  -- find the quickfix window
  local qf_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.getwininfo(win)[1].quickfix == 1 then
      qf_win = win
      break
    end
  end
  if not qf_win then return end

  vim.api.nvim_win_call(qf_win, function()
    vim.fn.clearmatches()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    for lnum, line in ipairs(lines) do
      -- Find the second pipe `|`, then highlight only in the text that follows
      local first_pipe = line:find("|", 1, true)
      if first_pipe then
        local second_pipe = line:find("|", first_pipe + 1, true)
        if second_pipe then
          local desc_start = second_pipe + 1
          local desc = line:sub(desc_start)
          local match_start = desc:lower():find(pattern:lower(), 1, true)
          if match_start then
            local col = desc_start + match_start - 1
            vim.fn.matchaddpos('Search', { { lnum, col, #pattern } }, 10)
          end
        end
      end
    end
  end)
end
