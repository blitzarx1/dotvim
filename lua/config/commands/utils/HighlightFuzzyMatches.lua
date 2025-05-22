local function get_match_positions(query, line)
  local P, T = query:lower(), line:lower()
  local m, n = #P, #T
  local pos, dp, cont, back = {}, {}, {}, {}
  for i = 1, m do pos[i], dp[i], cont[i], back[i] = {}, {}, {}, {} end

  for i = 1, m do
    for j = 1, n do
      if P:sub(i,i) == T:sub(j,j) then
        pos[i][#pos[i]+1] = j
      end
    end
  end

  for jidx = 1, #pos[1] do
    dp[1][jidx], cont[1][jidx], back[1][jidx] = 1, 1, nil
  end

  for i = 2, m do
    for jidx, pj in ipairs(pos[i]) do
      local best_score, best_run, best_k = 0, 0, nil
      for kidx, pk in ipairs(pos[i-1]) do
        if pk < pj then
          local ps, pr = dp[i-1][kidx] or 0, cont[i-1][kidx] or 0
          local run, score
          if pk + 1 == pj then
            run   = pr + 1
            score = ps - (pr^2) + (run^2)
          else
            run   = 1
            score = ps + 1
          end
          if score > best_score then
            best_score, best_run, best_k = score, run, kidx
          end
        end
      end
      dp[i][jidx], cont[i][jidx], back[i][jidx] = best_score, best_run, best_k
    end
  end

  -- pick the best endpoint
  local end_j, best_score = nil, 0
  for jidx, sc in ipairs(dp[m] or {}) do
    if sc > best_score then best_score, end_j = sc, jidx end
  end
  if not end_j then return {} end

  -- walk back
  local cols = {}
  local i, jidx = m, end_j
  while i >= 1 and jidx do
    table.insert(cols, 1, pos[i][jidx])
    jidx = back[i][jidx]
    i = i - 1
  end
  return cols
end

function HighlightFuzzyMatches(query)
  for lnum = 1, vim.fn.line('$') do
    local line = vim.fn.getline(lnum)
    local cols = get_match_positions(query, line)
    if #cols > 0 then
      local pos = {}
      for _, c in ipairs(cols) do pos[#pos+1] = { lnum, c, 1 } end
      vim.fn.matchaddpos('Search', pos, 10)
    end
  end
end

