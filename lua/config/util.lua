local M = {}

--- Get a concrete buffer number
--- @param bufnr integer? An optional buffer number. `nil` and `0` are coerced to the current buffer.
--- @return integer bufnr A buffer number.
function M.buffer_number(bufnr)
  if bufnr == nil or bufnr < 1 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return bufnr
end

-- Toggling diagnostics (for LSP, etc)
-- ===================================

--- @type table<integer, boolean> enablement per buffer; index -1 represents "global" enablement
M.diagnostic_state = { [-1] = true }
-- I am aware of `vim.diagnostic.is_enabled`, but I want to differentiate between "enabled", "disabled", and "unset"

--- toggle displaying inline diagnostics in a buffer
--- @param bufnr integer? a buffer number. `nil` and `0` indicate the current buffer.
--- @param enable boolean? explicitly enable or disable diagnostics. toggles when param is `nil`.
function M.diagnostics_toggle_buffer(bufnr, enable)
  bufnr = M.buffer_number(bufnr)

  if enable == nil then
    -- find our current state
    local buf_state = M.diagnostic_state[bufnr]
    local global_state = M.diagnostic_state[-1]

    -- if we started in an explicit state that differs from the global state, then reset to global
    if buf_state ~= nil and buf_state ~= global_state then
      M.diagnostics_reset_buffer(bufnr)
      return
    end

    -- otherwise, set the buffer to the inverse of global
    enable = not global_state
  end

  if enable then
    vim.notify("Enabling diagnostics in buffer")
  else
    vim.notify("Disabling diagnostics in buffer")
  end

  M.diagnostic_state[bufnr] = enable
  vim.diagnostic.enable(enable, { bufnr = bufnr })
end

--- Reset buffer's inline diagnostics display state to the global value.
--- @param bufnr integer the buffer to reset. `nil` and `0` indicate the current buffer.
function M.diagnostics_reset_buffer(bufnr)
  bufnr = M.buffer_number(bufnr)
  -- clear buffer state & match global
  local global_state = M.diagnostic_state[-1]
  if global_state then
    vim.notify("Clearing diagnostics toggle (enabled globally)")
  else
    vim.notify("Clearing diagnostics toggle (disabled globally)")
  end
  M.diagnostic_state[bufnr] = nil
  vim.diagnostic.enable(global_state, { bufnr = bufnr })
end

--- Toggle displaying inline diagnostics' global value.
--- Buffers that have not otherwise been enabled or disabled will use the
--- global value.
--- @param enable boolean? explicitly enable or disable. toggle when `nil`.
function M.diagnostics_toggle_global(enable)
  -- fetch, toggle, and store global state
  if enable == nil then
    enable = not M.diagnostic_state[-1]
  end
  M.diagnostic_state[-1] = enable

  -- give notice
  if enable then
    vim.notify("Enabling diagnostics globally")
  else
    vim.notify("Disabling diagnostics globally")
  end

  -- for each buffer
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- if it does not have an explicit diagnostic state:
    if M.diagnostic_state[bufnr] == nil then
      -- set appropriate diagnostic state
      vim.diagnostic.enable(enable, { bufnr = bufnr })
    end
  end
end

--- Apply
--- @param bufnr integer? buffer number. `nil` and `0` indicate the current buffer.
function M.update_buffer_diagnostics(bufnr)
  -- find our current state
  bufnr = M.buffer_number(bufnr)
  local buf_state = M.diagnostic_state[bufnr]
  local global_state = M.diagnostic_state[-1]

  vim.diagnostic.enable(buf_state or (buf_state == nil and global_state), { bufnr = bufnr })
end

--- Combine two or more sets (arrays with unique members).
--- Mutates and returns the first argument. To create a new unique array, pass
--- an empty array first.
--- @generic T
--- @param first T[]
--- @param ... T[]
--- @return T[] result the resulting set
function M.set_add(first, ...)
  --- @alias T T
  local rest = { ... }

  -- special case: adding a single item
  if #rest == 1 then
    local _, other = next(rest)
    if other and #other == 1 then
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

  --- @type table<T, true> the set of elements in the first list
  local element_set = {}
  for _, elem in ipairs(first) do
    element_set[elem] = true
  end

  --- @type table<T, true> the set of elements to be added to the first list
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

--- get or create a nested table, following the given chain of lookup keys. mutates `tbl`
--- @param tbl table
--- @param ... string | integer
--- @return table tbl
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

-- add a workspace folder to a specific LSP client. If a matching workspace
-- folder already exists, silently do nothing
--- @param client vim.lsp.Client
--- @param folder string
--- @return nil
function M.lsp_client_add_workspace_folder(client, folder)
  --- @type lsp.WorkspaceFolder[]
  local client_ws_folders = client.workspace_folders or {}
  for _, ws_folder in ipairs(client_ws_folders) do
    if folder == ws_folder.name then
      return
    end
  end

  --- @type lsp.WorkspaceFolder
  local new_workspace_folder = {
    uri = vim.uri_from_fname(folder),
    name = folder,
  }

  client:notify("workspace/didChangeWorkspaceFolders", {
    event = {
      added = { new_workspace_folder },
      removed = {},
    },
  })

  --- @type lsp.WorkspaceFolder[]
  client.workspace_folders = vim.list_extend(client.workspace_folders or {}, { new_workspace_folder })
end

function M.clean_win_path()
  if vim.env.OS ~= "Windows_NT" then
    -- This isn't windows!
    return
  end

  -- get our PATH list
  local path = vim.split(vim.env.PATH, ";")
  -- vim.notify(string.format("Found path: %s", vim.inspect(path)))

  -- define directory rejection rules
  local reject_pattern = vim.regex("\\v\\c<(git\\\\mingw64|git\\\\usr\\\\bin|cygwin)>")

  -- build a "clean" path list
  local clean_path = {}
  for _, dir in ipairs(path) do
    if not reject_pattern:match_str(dir) then
      -- vim.notify(string.format("Accepting: %s", dir))
      table.insert(clean_path, dir)
      -- else
      --   vim.notify(string.format("Rejecting: %s", dir))
    end
  end

  -- replace the PATH
  vim.env.PATH = table.concat(clean_path, ";")
  -- vim.notify(string.format("New path is: %s", vim.env.PATH))
end

function M.fix_shell_settings()
  local path_sep = vim.split(package.config, "\n")[1]
  local shell_parts = vim.split(vim.o.shell, path_sep)
  local shell = shell_parts[#shell_parts]
  -- vim.notify(string.format("Shell is %s (%s)", shell, vim.o.shell))

  if string.find(shell, "sh") and string.find(vim.o.shellcmdflag, "^/") then
    -- vim.notify("Changing shellcmdflag to `-c`")
    vim.o.shellcmdflag = "-c"
  elseif string.find(shell, "cmd") and string.find(vim.o.shellcmdflag, "^-") then
    -- vim.notify("Changing shellcmdflag to `/s /c`")
    vim.o.shellcmdflag = "/s /c"
  end
end

-- Toggling Treesitter Highlighting
-- ================================

--- @type table<integer, boolean> enablement per buffer; index -1 represents "global" enablement
M.treesitter_state = { [-1] = true }

--- toggle treesitter highlighting in a buffer
--- @param enable boolean? explicitly enable or disable treesitter. toggle when `nil`.
--- @param bufnr integer? buffer number. defaults to current buffer
function M.treesitter_toggle_buffer(enable, bufnr)
  bufnr = M.buffer_number(bufnr)

  if enable == nil then
    local buf_state = M.treesitter_state[bufnr]
    local global_state = M.treesitter_state[-1]

    -- if we started in an explicit state that differs from the global state, then reset to global
    if buf_state ~= nil and buf_state ~= global_state then
      M.treesitter_reset_buffer(bufnr)
      return
    end

    -- otherwise, set the buffer to the inverse of global
    enable = not global_state
  end

  if enable then
    vim.notify("Enabling treesitter highlighting in buffer")
    vim.treesitter.start(bufnr)
    vim.treesitter.query.lint(bufnr)
  else
    vim.notify("Disabling treesitter highlighting in buffer")
    vim.treesitter.stop(bufnr)
    vim.treesitter.query.lint(bufnr, { clear = true })
  end

  M.treesitter_state[bufnr] = enable
end

function M.treesitter_reset_buffer(bufnr)
  error("Not Implemented :(")

  bufnr = M.buffer_number(bufnr)
  local global_state = M.treesitter_state[-1]
  if global_state then
    vim.notify("Clearing treesitter toggle (enabled globally)")
  else
    vim.notify("Clearing treesitter toggle (disabled globally)")
  end
  M.diagnostic_state[bufnr] = nil
  vim.diagnostic.enable(global_state, { bufnr = bufnr })
end

return M
