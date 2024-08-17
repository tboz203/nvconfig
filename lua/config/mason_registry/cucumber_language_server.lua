return require("mason-core.package").new({
  schema = "registry+v1",
  name = "cucumber-language-server",
  description = "Cucumber Language Server.",
  homepage = "https://github.com/cucumber/language-server",
  licenses = {
    "MIT",
  },
  languages = {
    "Cucumber",
  },
  categories = {
    "LSP",
  },
  source = {
    -- id = "pkg:github/cucumber/language-server@v1.2.0",
    id = "pkg:github/cucumber/language-server@v1.6.0",
    build = {
      env = {
        -- force install with nodejs 22 (currently provided by nodenv)
        -- (needs to also be specified in lspconfig)
        NODENV_VERSION = "22.4.1",
        -- replace upstream tree-sitter-cli with locally built & packaged
        -- version to fix GLIBC dependency
        TREE_SITTER_CLI_TARBALL = vim.fn.stdpath("config") .. "/data/tree-sitter-cli.tar.gz",
      },
      run = "npm install $TREE_SITTER_CLI_TARBALL\nnpm run build",
    },
  },
  bin = {
    ["cucumber-language-server"] = "bin/cucumber-language-server.cjs",
  },
})
