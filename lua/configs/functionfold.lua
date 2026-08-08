-- Fold on function nodes only via treesitter. nvim-treesitter#foldexpr()
-- folds every scope (classes, if/for, structs, ...) which buries functions
-- in noise; this walks the tree and only emits folds for function-shaped
-- nodes across languages.
local M = {}

local FUNCTION_TYPES = {
  function_declaration = true, -- go, js/ts, zig, c
  function_definition = true, -- python, c
  function_item = true, -- rust
  method_declaration = true, -- go, java
  method_definition = true, -- js/ts, python (some grammars)
  arrow_function = true, -- js/ts
  func_literal = true, -- go closures
}

local cache = {} -- bufnr -> { tick, level = {[lnum]=depth}, starts = {[lnum]=depth} }

local function compute(bufnr)
  if vim.api.nvim_buf_line_count(bufnr) > 10000 then
    return nil
  end
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil
  end
  local trees = parser:parse()
  local root = trees[1] and trees[1]:root()
  if not root then
    return nil
  end

  local nlines = vim.api.nvim_buf_line_count(bufnr)
  local level = {}
  local starts = {}

  local function walk(node, depth)
    local d = depth
    if FUNCTION_TYPES[node:type()] then
      d = depth + 1
      local srow, _, erow = node:range()
      starts[srow + 1] = d
      for l = srow + 1, math.min(erow + 1, nlines) do
        level[l] = math.max(level[l] or 0, d)
      end
    end
    for child in node:iter_children() do
      walk(child, d)
    end
  end

  walk(root, 0)
  return { tick = vim.api.nvim_buf_get_changedtick(bufnr), level = level, starts = starts }
end

function M.clear_cache(bufnr)
  cache[bufnr] = nil
end

function M.foldexpr()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.v.lnum
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)

  local c = cache[bufnr]
  if not c or c.tick ~= tick then
    c = compute(bufnr)
    cache[bufnr] = c
  end
  if not c then
    return "0"
  end

  if c.starts[lnum] then
    return ">" .. c.starts[lnum]
  end
  return tostring(c.level[lnum] or 0)
end

return M
