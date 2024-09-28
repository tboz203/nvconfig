local M = {}
local lazyutil = require("lazy.core.util")
local util = require("config.util")
local Path = util.Path

-- add a directory to Pyright's package search path
---@param client vim.lsp.Client?
---@param ... string
---@return nil
function M.pyright_add_extra_paths(client, ...)
  local paths = { ... }
  if not next(paths) then
    paths = { vim.api.nvim_buf_get_name(0) }
  end

  ---@type vim.lsp.Client[]
  local client_list
  if client then
    client_list = { client }
  else
    client_list = vim.lsp.get_clients({ name = "pyright" })
  end

  for _, client in ipairs(client_list) do
    local settings = client.settings or client.config.settings
    local extra_paths = util.deepen(settings, "python", "analysis", "extraPaths")
    util.set_add(extra_paths, paths)
    client.notify("workspace/didChangeConfiguration", { settings = settings })
  end
end

-- tell pyright which python executable we use
---@param client vim.lsp.Client?
---@param path string
---@return nil
function M.pyright_set_python_path(client, path)
  ---@type vim.lsp.Client[]
  local client_list
  if client then
    client_list = { client }
  else
    client_list = vim.lsp.get_clients({ name = "pyright" })
  end

  for _, client_ in ipairs(client_list) do
    lazyutil.merge(client_.config.settings, {
      python = {
        pythonPath = path,
      },
    })

    client_.notify("workspace/didChangeConfiguration", { settings = client_.config.settings })
  end
end

-- toggle Pyright's diagnostic mode between "workspace" and "openFilesOnly"
---@return nil
function M.pyright_toggle_diagnostic_mode()
  for _, client in pairs(vim.lsp.get_clients({ name = "pyright" })) do
    local settings = client.settings or client.config.settings
    local current_mode = vim.tbl_get(settings, "python", "analysis", "diagnosticMode")
    local new_mode
    if current_mode == nil or current_mode == "workspace" then
      new_mode = "openFilesOnly"
    else
      new_mode = "workspace"
    end
    lazyutil.merge(settings, {
      python = {
        analysis = {
          diagnosticMode = new_mode,
        },
      },
    })
    client.notify("workspace/didChangeConfiguration", { settings = nil })
    vim.notify(string.format("Set Pyright diagnostic mode to `%s`", new_mode), vim.log.levels.INFO)
  end
end

-- find closest ancestor of path `fname` whose parent directory does not contain an `__init__.py`
---@param fname string
---@return string?
function M.find_package_root(fname)
  ---@type Path
  local filepath = Path:new(fname)
  if not filepath:is_dir() then
    filepath = filepath:parent()
  end
  if not filepath:exists() then
    return nil
  end
  while true do
    local parent = filepath:parent()
    if parent == filepath then
      -- found filesystem root?
      return tostring(filepath)
    end
    if not (parent / "__init__.py"):exists() then
      -- nothing further up; this is the top directory in the package
      return tostring(filepath)
    end
    filepath = parent
  end
end

-- find a python virtual environment based on a filename. currently only searches along parents path for venvs
function M.find_venv(fname)
  local fpath = Path.new(Path.new(fname):absolute())

  local venv_names = {
    "venv/pyvenv.cfg",
    ".venv/pyvenv.cfg",
  }

  -- traverse self and parent directories looking for `.../venv/pyvenv.cfg`
  local pyvenv_cfg = fpath:find_any_upwards(unpack(venv_names))

  -- if we find that,
  if pyvenv_cfg then
    -- return the path to the `venv` folder
    return tostring(pyvenv_cfg:parent())
  end

  -- else complain
  vim.notify("Failed to find venv for path: " .. tostring(fpath), vim.log.levels.DEBUG)
  return nil
end

---@param key string
---@param value any
---@return nil
function M.ruff_change_setting(key, value)
  -- lua's regular expressions don't allow repeating groups?!? (eg. `(...)*`)
  -- if not string.match(key, "^%w+(%.%w+)*$") then
  --   error("Not a valid setting: " .. key)
  -- end

  -- attempt to evaluate `value` as lua
  pcall(function()
    local f = loadstring("return " .. value)
    if f then
      value = f()
    end
  end)

  ---@type string[]
  local split_keys = {}
  for part in string.gmatch(key, "%w+") do
    split_keys[#split_keys + 1] = part
  end

  local bottom_key = split_keys[#split_keys]
  split_keys[#split_keys] = nil

  for _, client in ipairs(vim.lsp.get_clients({ name = "ruff" })) do
    vim.notify("updating ruff configuration", vim.log.levels.INFO)
    local settings =
      vim.tbl_deep_extend("force", util.deepen(client.config, "init_options", "settings"), client.settings or {})
    local bottom_setting_table = util.deepen(settings, unpack(split_keys))
    bottom_setting_table[bottom_key] = value
    client.stop()

    local timer = vim.uv.new_timer()
    local attempts = 0
    timer:start(100, 1, function()
      if not client.is_stopped() and attempts < 300 then
        vim.notify("ruff not yet stopped", vim.log.levels.INFO)
        attempts = attempts + 1
        if attempts > 250 then
          client.stop(true)
        end
        return
      end
      vim.notify("ruff is stopped", vim.log.levels.INFO)
      timer:stop()
      timer:close()
      vim.schedule(function()
        vim.notify("restarting ruff", vim.log.levels.INFO)
        require("lspconfig").ruff.setup({
          init_options = {
            settings = settings,
          },
        })
      end)
    end)
  end
end

return M
