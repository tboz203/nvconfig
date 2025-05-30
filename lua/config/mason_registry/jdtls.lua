-- Replacing https://projectlombok.org/downloads/lombok.jar
-- with https://repo1.maven.org/maven2/org/projectlombok/lombok/1.18.36/lombok-1.18.36.jar
return require("mason-core.package").new({
  schema = "registry+v1",
  name = "jdtls",
  description = "Java language server.",
  homepage = "https://github.com/eclipse/jdt.ls",
  licenses = {
    "EPL-2.0",
  },
  languages = {
    "Java",
  },
  categories = {
    "LSP",
  },
  source = {
    id = "pkg:generic/eclipse/eclipse.jdt.ls@v1.44.0",
    download = {
      {
        target = {
          "darwin_x64",
          "darwin_arm64",
        },
        files = {
          ["jdtls.tar.gz"] = 'https://download.eclipse.org/jdtls/milestones/{{ version | strip_prefix "v" }}/jdt-language-server-{{ version | strip_prefix "v" }}-202501221502.tar.gz',
          ["lombok.jar"] = "https://repo1.maven.org/maven2/org/projectlombok/lombok/1.18.36/lombok-1.18.36.jar",
        },
        config = "config_mac/",
      },
      {
        target = "linux",
        files = {
          ["jdtls.tar.gz"] = 'https://download.eclipse.org/jdtls/milestones/{{ version | strip_prefix "v" }}/jdt-language-server-{{ version | strip_prefix "v" }}-202501221502.tar.gz',
          ["lombok.jar"] = "https://repo1.maven.org/maven2/org/projectlombok/lombok/1.18.36/lombok-1.18.36.jar",
        },
        config = "config_linux/",
      },
      {
        target = "win",
        files = {
          ["jdtls.tar.gz"] = 'https://download.eclipse.org/jdtls/milestones/{{ version | strip_prefix "v" }}/jdt-language-server-{{ version | strip_prefix "v" }}-202501221502.tar.gz',
          ["lombok.jar"] = "https://repo1.maven.org/maven2/org/projectlombok/lombok/1.18.36/lombok-1.18.36.jar",
        },
        config = "config_win/",
      },
    },
  },
  schemas = {
    lsp = "vscode:https://raw.githubusercontent.com/redhat-developer/vscode-java/master/package.json",
  },
  bin = {
    jdtls = "python:bin/jdtls",
  },
  share = {
    ["jdtls/lombok.jar"] = "lombok.jar",
    ["jdtls/plugins/"] = "plugins/",
    ["jdtls/plugins/org.eclipse.equinox.launcher.jar"] = "plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar",
    ["jdtls/config/"] = "{{source.download.config}}",
  },
})
