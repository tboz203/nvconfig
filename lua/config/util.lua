local Path = require("plenary.path")

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

local M = {}

-- lenient deep table lookup
function M.lookup(tbl, ...)
  for _, key in ipairs({ ... }) do
    if type(tbl) ~= "table" then
      return nil
    end
    tbl = tbl[key]
  end
  return tbl
end

function M.find_root_dir(fname)
  local util = require("lspconfig.util")
  -- based on function from pylsp lspconfig; removed `setup.py` to prevent false positives
  local root_files = {
    "requirements.txt",
    "requirements.in",
    "setup.cfg",
    "pyproject.toml",
    "Pipfile",
  }
  return (
    util.root_pattern(unpack(root_files))(fname)
    or util.find_git_ancestor(fname)
    or util.find_mercurial_ancestor(fname)
  )
end

-- table of functions to set python paths per lsp client
M.python_paths_hooks = {
  pyright = function(client, python_path)
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
      python = {
        pythonPath = python_path,
      },
    })
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

    local extra_paths = M.lookup(client, "config", "settings", "pylsp", "plugins", "jedi", "extra_paths") or {}
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
-- currently only searches along parents path for "venv/pyvenv.cfg"
function M.find_venv(fname)
  local fpath = Path.new(Path.new(fname):absolute())

  -- traverse self and parent directories looking for `.../venv/pyvenv.cfg`
  local pyvenv_cfg = fpath:find_upwards("venv/pyvenv.cfg")

  if pyvenv_cfg then
    -- if we find that, return the path to the `venv` folder
    return tostring(pyvenv_cfg:parent())
  end

  -- else complain
  vim.notify("Failed to find venv for path: " .. tostring(fpath), vim.log.levels.DEBUG)
  return nil
end

-- shortcut function wiring together `find_venv` and `set_python_paths`
function M.set_lsp_for_venv(fname)
  fname = fname or vim.api.nvim_buf_get_name(0)
  local venv = M.find_venv(fname)
  if venv then
    M.set_python_paths(venv .. "/bin/python")
  end
end

-- lsp on_attach callback wiring together `find_venv` per buffer name and `python_path_hooks`
function M.set_client_venv_paths(client, bufnr)
  if client.config.venv_check_done then
    vim.notify("short-circuiting venv set; already done", vim.log.levels.DEBUG)
    return
  end

  client.config.venv_check_done = true
  local venv = M.find_venv(vim.api.nvim_buf_get_name(bufnr))
  if venv == nil then
    return
  end
  local set_paths_hook = M.python_paths_hooks[client.name]
  if set_paths_hook == nil then
    vim.notify("lsp client venv python paths hook not found", vim.log.levels.DEBUG)
    return
  end

  vim.notify(string.format("setting python paths for %s client from %s", client.name, venv), vim.log.levels.INFO)
  set_paths_hook(client, venv .. "/bin/python")
end

return M
