local M = {}
local util = require("config.util")
local Path = util.Path

-- toggle pyright lsp between analysing workspace & only open files
function M.toggle_pyright_diagnostic_mode()
  for _, client in pairs(vim.lsp.get_active_clients({ name = "pyright" })) do
    local current_mode = util.lookup(client.config.settings, "python", "analysis", "diagnosticMode")
    local new_mode
    if current_mode == nil or current_mode == "workspace" then
      new_mode = "openFilesOnly"
    else
      new_mode = "workspace"
    end
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
      python = {
        analysis = {
          diagnosticMode = new_mode,
        },
      },
    })
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    vim.notify(string.format("Set Pyright diagnostic mode to `%s`", new_mode), vim.log.levels.INFO)
  end
end

-- given a filename in a python project, determine its project root directory
function M.find_root_dir(fname)
  local lsputil = require("lspconfig.util")
  local root = Path.path.root(fname)
  local ancestor = Path.new(fname)
  while true do
    if ancestor:basename() == "site-packages" then
      -- if we're already in a site-packages directory, don't add anything
      return nil
    end
    if ancestor:absolute() == root then
      break
    end
    ancestor = ancestor:parent()
  end
  -- based on function from pylsp lspconfig; removed `setup.py` to prevent false positives
  local root_files = {
    "requirements.txt",
    "requirements.in",
    "setup.cfg",
    "pyproject.toml",
    "Pipfile",
  }
  return (
    lsputil.root_pattern(unpack(root_files))(fname)
    or lsputil.find_git_ancestor(fname)
    or lsputil.find_mercurial_ancestor(fname)
  )
end

-- table of functions to set python paths per lsp client
M.python_paths_hooks = {
  pyright = function(client, python_path)
    -- look and see if there's a project stubs directory
    local analysis_with_extra_paths = nil
    local maybe_stubs = Path.new(client.config.root_dir, ".stubs")
    if maybe_stubs:exists() then
      analysis_with_extra_paths = {
        extraPaths = { maybe_stubs:absolute() },
      }
    end
    -- modify our settings
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
      python = {
        pythonPath = python_path,
        analysis = analysis_with_extra_paths,
      },
    })
    -- notify the server
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end,
  pylsp = function(client, python_path)
    local command = python_path .. " -c 'import site; print(site.getsitepackages()[0])'"
    local output = io.popen(command):read("*a"):gsub("%s+$", "")
    local site_packages = Path.new(output)
    if not (site_packages and site_packages:exists()) then
      vim.notify("Failed to find site packages for interpreter: " .. python_path, vim.log.levels.WARN)
      return
    end

    local extra_paths = util.lookup(client, "config", "settings", "pylsp", "plugins", "jedi", "extra_paths") or {}
    table.insert(extra_paths, tostring(site_packages))
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
      pylsp = {
        plugins = {
          jedi = {
            extra_paths = extra_paths,
          },
        },
      },
    })
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end,
}

-- set python interpreter and/or site-packages paths for all active python LSPs
function M.set_python_paths(python_path)
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    local set_paths_hook = M.python_paths_hooks[client.name]
    if set_paths_hook then
      set_paths_hook(python_path)
    end
  end
end

-- find a python virtual environment based on a filename
-- currently only searches along parents path for venvs
function M.find_venv(fname)
  local unpack = unpack or table.unpack
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

-- shortcut function wiring together `find_venv` and `set_python_paths`
function M.set_venv_for_lsp(fname)
  fname = fname or vim.api.nvim_buf_get_name(0)
  local venv = M.find_venv(fname)
  if venv then
    M.set_python_paths(venv .. "/bin/python")
  end
end

-- lsp on_attach callback wiring together `find_venv` per buffer name and `python_path_hooks`
function M.set_client_venv_paths(client, bufnr)
  -- first check for hook; if there isn't one, nothing to do
  local set_paths_hook = M.python_paths_hooks[client.name]
  if set_paths_hook == nil then
    return
  end

  -- then check/set our already-done flag
  if client.config.venv_check_done then
    return
  else
    client.config.venv_check_done = true
  end

  local venv = M.find_venv(vim.api.nvim_buf_get_name(bufnr))
  if venv == nil then
    return
  end

  vim.notify(string.format("setting python paths for %s client from %s", client.name, venv), vim.log.levels.INFO)
  set_paths_hook(client, venv .. "/bin/python")
end

return M
