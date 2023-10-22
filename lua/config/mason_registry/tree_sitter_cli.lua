return require("mason-core.package").new({
  schema = "registry+v1",
  name = "tree-sitter-cli",
  description = "The Tree-sitter CLI allows you to develop, test, and use Tree-sitter grammars from the command line. It works on\nMacOS, Linux, and Windows.\n",
  homepage = "https://github.com/tree-sitter/tree-sitter/blob/master/cli/README.md",
  licenses = {
    "MIT",
  },
  languages = {},
  categories = {
    "Compiler",
  },
  source = {
    id = "pkg:cargo/tree-sitter-cli@~0.20",
  },
  bin = {
    ["tree-sitter"] = "cargo:tree-sitter",
  },
})
