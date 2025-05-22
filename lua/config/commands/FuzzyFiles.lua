-- 1) build an “h.*a.*n.*d” style regex from your query
local function build_subseq_regex(query)
  local parts = {}
  for c in query:lower():gmatch('.') do parts[#parts+1] = c end
  return table.concat(parts, '.*')
end

-- 2) run `find . | grep -iE …` to filter down to candidates
local function find_candidates(regex)
  return vim.fn.systemlist("find . | grep -iE '" .. regex .. "'")
end

-- 3) DP-score = sum of squares of *all* contiguous match runs
local function score_contiguous(query, path)
  local P, T = query:lower(), path:lower()
  local m, n = #P, #T
  local pos, dp, cont = {}, {}, {}
  for i = 1, m do pos[i], dp[i], cont[i] = {}, {}, {} end

  -- collect match positions for each pattern char
  for i = 1, m do
    for j = 1, n do
      if P:sub(i,i) == T:sub(j,j) then
        pos[i][#pos[i]+1] = j
      end
    end
  end

  -- base case: first char always gives a run of length 1 → score 1
  for j = 1, #pos[1] do
    dp[1][j], cont[1][j] = 1, 1
  end

  -- fill DP
  for i = 2, m do
    for jidx, pj in ipairs(pos[i]) do
      local best_score, best_run = 0, 0
      for kidx, pk in ipairs(pos[i-1]) do
        if pk < pj then
          local prev_score = dp[i-1][kidx] or 0
          local prev_run   = cont[i-1][kidx] or 0
          local run, score
          if pk + 1 == pj then
            run   = prev_run + 1
            score = prev_score - (prev_run^2) + (run^2)
          else
            run   = 1
            score = prev_score + 1
          end
          if score > best_score then
            best_score, best_run = score, run
          end
        end
      end
      dp[i][jidx], cont[i][jidx] = best_score, best_run
    end
  end

  -- answer = max over dp[m][*]
  local max_score = 0
  for _, v in ipairs(dp[m] or {}) do
    if v > max_score then max_score = v end
  end
  return max_score
end

-- 4) DP back-trace to get exactly which columns to highlight
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

-- 5) sort all candidates by descending DP score, then alpha
local function rank_paths(paths, query)
  local scored = {}
  for _, p in ipairs(paths) do
    local s = score_contiguous(query, p)
    if s > 0 then scored[#scored+1] = { path = p, score = s } end
  end
  table.sort(scored, function(a,b)
    if a.score ~= b.score then
      return a.score > b.score
    end
    return a.path < b.path
  end)
  local out = {}
  for _, e in ipairs(scored) do out[#out+1] = e.path end
  return out
end

-- 6) shove into quickfix and highlight
local function show_quickfix(paths)
  local qf = {}
  for _, p in ipairs(paths) do
    qf[#qf+1] = { filename = p, lnum = 1, col = 1 }
  end
  vim.fn.setqflist(qf)
  vim.cmd('copen')
  vim.fn.clearmatches()
end

local function highlight_matches(query)
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

function FuzzyFiles(pattern)
  local q = pattern:gsub('%s+', '')
  if q == '' then return end
  local regex     = build_subseq_regex(q)
  local candidates= find_candidates(regex)
  local ranked    = rank_paths(candidates, q)
  show_quickfix(ranked)
  highlight_matches(q)
end

-- 8) expose to :FuzzyFiles
vim.api.nvim_create_user_command('FuzzyFiles', function(opts)
  FuzzyFiles(opts.args)
end, { nargs = 1, desc = 'fuzzy find files → quickfix' })

