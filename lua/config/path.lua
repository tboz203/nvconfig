---@class Path
local Path = require("plenary.path")

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
---@param ... string
---@return string?
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

---@return string
function Path:basename()
  local parts = vim.split(self.filename, Path.path.sep)
  return parts[#parts]
end

-- allow calling `Path` as a constructor
setmetatable(Path, {
  __call = Path.new,
})

return Path
