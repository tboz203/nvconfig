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

-- "print inspect": wrapper for `print(vim.inspect(...))`
function M.pi(...)
  return print(vim.inspect(...))
end
-- may consider making this a global...

return M
