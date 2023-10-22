-- alternate spec for stylua that builds via cargo instead of downloading a
-- binary
return require("mason-core.package").new({
  schema = "registry+v1",
  name = "stylua",
  description = "An opinionated Lua code formatter.",
  homepage = "https://github.com/JohnnyMorganz/StyLua",
  licenses = {
    "MPL-2.0",
  },
  languages = {
    "Lua",
    "Luau",
  },
  categories = {
    "Formatter",
  },
  source = {
    id = "pkg:cargo/stylua@~0.18",
  },
  bin = {
    stylua = "cargo:stylua",
  },
})
