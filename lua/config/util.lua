local M = {}
---@class Path
local Path = require("plenary.path")
M.Path = Path

-- overriding Path:find_upwards because as of 2023-09-29 if a matching file is
-- not found, it enters an infinite loop and hangs the whole editor
---@diagnostic disable-next-line
function Path:find_upwards(filename)
  local folder = Path:new(self)
  local root = Path.path.root()
  while folder:absolute() ~= root do
    local p = folder:joinpath(filename)
    if p:exists() then
      return p
    end
    folder = folder:parent()
  end
  return nil
end

-- corrected & extended version of `Path:find_upwards`
function Path:find_any_upwards(...)
  local folder = Path:new(self)
  local root = Path.path.root()
  while folder:absolute() ~= root do
    for _, filename in pairs({ ... }) do
      local p = folder:joinpath(filename)
      if p:exists() then
        return p
      end
    end
    folder = folder:parent()
  end
  return nil
end

function Path:basename()
  return self.filename:gsub("^.*/", "")
end

-- toggling diagnostics (for LSP, etc)
M.diagnostic_state = { [-1] = true }

function M.toggle_current_buffer_diagnostics()
  -- find our current state
  local buf_id = vim.api.nvim_get_current_buf()
  local buf_state = M.diagnostic_state[buf_id]
  local global_state = M.diagnostic_state[-1]

  -- if we match global state (explicit or otherwise) then
  if buf_state == nil or buf_state == global_state then
    -- set to !global_state
    if global_state then
      M.diagnostic_state[buf_id] = false
      vim.notify("Disabling diagnostics in buffer")
      vim.diagnostic.enable(false, { bufnr = buf_id })
    else
      M.diagnostic_state[buf_id] = true
      vim.notify("Enabling diagnostics in buffer")
      vim.diagnostic.enable(true, { bufnr = buf_id })
    end
  else
    -- otherwise clear buffer state & match global
    M.diagnostic_state[buf_id] = nil
    if global_state then
      vim.notify("Clearing diagnostics toggle (enabled globally)")
      vim.diagnostic.enable(true, { bufnr = buf_id })
    else
      vim.notify("Clearing diagnostics toggle (disabled globally)")
      vim.diagnostic.enable(false, { bufnr = buf_id })
    end
  end
end

function M.toggle_global_diagnostics()
  -- fetch, toggle, and store global state
  local global_state = not M.diagnostic_state[-1]
  M.diagnostic_state[-1] = global_state

  -- give notice
  if global_state then
    vim.notify("Enabling diagnostics globally")
  else
    vim.notify("Disabling diagnostics globally")
  end

  -- for each buffer
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    -- if it does not have an explicit diagnostic state:
    if M.diagnostic_state[buf_id] == nil then
      -- set appropriate diagnostic state
      if global_state then
        vim.diagnostic.enable(true, { bufnr = buf_id })
      else
        vim.diagnostic.enable(false, { bufnr = buf_id })
      end
    end
  end
end

-- enable or disable diagnostics in the current buffer based on our state
function M.update_current_buffer_diagnostics()
  -- find our current state
  local buf_id = vim.api.nvim_get_current_buf()
  local buf_state = M.diagnostic_state[buf_id]
  local global_state = M.diagnostic_state[-1]

  if buf_state or (buf_state == nil and global_state) then
    vim.diagnostic.enable(true, { bufnr = buf_id })
  else
    vim.diagnostic.enable(false, { bufnr = buf_id })
  end
end

---@generic T
---@param first T[]
---@param ... T[]
---@return T[] set
--- Combine unique arrays. Mutates and returns the first argument.
--- To create a new unique array, pass an empty array first.
function M.set_add(first, ...)
  ---@alias T T
  local rest = { ... }

  -- special case: adding a single item
  if #rest == 1 then
    local _, other = next(rest)
    if #other == 1 then
      local _, right_elem = next(other)
      for _, item in ipairs(first) do
        if item == right_elem then
          return first
        end
      end
      first[#first + 1] = right_elem
      return first
    end
  end

  ---@type table<T, true>
  --- the set of elements in the first list
  local element_set = {}
  for _, elem in ipairs(first) do
    element_set[elem] = true
  end

  ---@type table<T, true>
  --- the set of elements to be added to the first list
  local additions = {}
  for _, other in ipairs(rest) do
    for _, elem in ipairs(other) do
      if not element_set[elem] then
        additions[elem] = true
      end
    end
  end

  for elem, _ in pairs(additions) do
    first[#first + 1] = elem
  end

  return first
end

function M.deepen(tbl, ...)
  local keys = { ... }
  local curr = tbl
  for i, key in ipairs(keys) do
    if type(curr) ~= "table" then
      error(vim.inspect({ message = "not a table", tbl = tbl, curr = curr, keys = keys, i = i }))
    end
    if curr[key] == nil then
      curr[key] = {}
    end
    curr = curr[key]
  end
  return curr
end

return M
