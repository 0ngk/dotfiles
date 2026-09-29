local function notify(message, level)
  vim.notify(message, level or vim.log.levels.WARN, { title = "nvim-jdtls" })
end

local lazy_ok, lazy = pcall(require, "lazy")
if lazy_ok then
  lazy.load({ plugins = { "nvim-jdtls" } })
end

local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  notify("nvim-jdtls is not available. Run lazy.nvim sync/install first.", vim.log.levels.ERROR)
  return
end

local root_markers = {
  "gradlew",
  "mvnw",
  ".git",
  "settings.gradle",
  "settings.gradle.kts",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "build.xml",
}

local function project_id(root_dir)
  local name = vim.fs.basename(root_dir) or "project"
  name = name:gsub("[^%w%._%-]", "_")
  if name == "" then
    name = "project"
  end

  return ("%s-%s"):format(name, vim.fn.sha256(root_dir):sub(1, 12))
end

local function os_config_dir_name()
  local uname = (vim.uv or vim.loop).os_uname()
  if uname.sysname == "Darwin" then
    return "config_mac"
  end
  if uname.sysname == "Windows_NT" then
    return "config_win"
  end
  return "config_linux"
end

local function executable(path)
  return type(path) == "string" and path ~= "" and vim.fn.executable(path) == 1
end

local function directory(path)
  return type(path) == "string" and path ~= "" and vim.fn.isdirectory(path) == 1
end

local function resolve_java_executable()
  local suffix = os_config_dir_name() == "config_win" and ".exe" or ""
  local java_home = vim.env.JAVA_HOME
  if type(java_home) == "string" and java_home ~= "" then
    local java_home_java = vim.fs.joinpath(java_home, "bin", "java" .. suffix)
    if executable(java_home_java) then
      return java_home_java
    end
  end

  local java = vim.fn.exepath("java")
  if java ~= "" then
    return java
  end
  if executable("java") then
    return "java"
  end
  return nil
end

local function java_major_version(java_cmd)
  local output
  if vim.system then
    local result = vim.system({ java_cmd, "-version" }, { text = true }):wait()
    output = table.concat({ result.stdout or "", result.stderr or "" }, "\n")
  else
    output = table.concat(vim.fn.systemlist(vim.fn.shellescape(java_cmd) .. " -version 2>&1"), "\n")
  end

  local version = output:match('version "([^"]+)"')
  if not version then
    return nil
  end
  if version:match("^1%.") then
    return tonumber(version:match("^1%.(%d+)"))
  end
  return tonumber(version:match("^(%d+)"))
end

local function resolve_launcher(jdtls_home)
  local launcher = vim.fs.joinpath(jdtls_home, "plugins", "org.eclipse.equinox.launcher.jar")
  if vim.fn.filereadable(launcher) == 1 then
    return launcher
  end

  local launchers =
    vim.fn.glob(vim.fs.joinpath(jdtls_home, "plugins", "org.eclipse.equinox.launcher_*.jar"), false, true)
  table.sort(launchers)
  return launchers[#launchers]
end

local function resolve_jdtls_cmd(jdtls_home, workspace_dir)
  if not directory(jdtls_home) then
    notify("JDTLS_HOME must point to an eclipse.jdt.ls installation directory.")
    return nil
  end

  local wrapper = vim.fs.joinpath(jdtls_home, "bin", os_config_dir_name() == "config_win" and "jdtls.bat" or "jdtls")
  if executable(wrapper) then
    return { wrapper, "-data", workspace_dir }
  end

  local java_cmd = resolve_java_executable()
  if not java_cmd then
    notify("Java executable was not found. eclipse.jdt.ls requires Java 21+.")
    return nil
  end

  local major = java_major_version(java_cmd)
  if major and major < 21 then
    notify(("eclipse.jdt.ls requires Java 21+ to run, but %s reports Java %d."):format(java_cmd, major))
    return nil
  end

  local launcher = resolve_launcher(jdtls_home)
  if not launcher then
    notify("Could not find org.eclipse.equinox.launcher_*.jar under JDTLS_HOME/plugins.")
    return nil
  end

  local config_dir = vim.fs.joinpath(jdtls_home, os_config_dir_name())
  if not directory(config_dir) then
    notify(("Could not find jdtls configuration directory: %s"):format(config_dir))
    return nil
  end

  return {
    java_cmd,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    launcher,
    "-configuration",
    config_dir,
    "-data",
    workspace_dir,
  }
end

local root_dir = vim.fs.root(0, root_markers)
if not root_dir then
  notify("jdtls was not started because no Java project root marker was found.")
  return
end

local jdtls_home = vim.env.JDTLS_HOME
if type(jdtls_home) ~= "string" or jdtls_home == "" then
  notify("JDTLS_HOME is not set. Set it to your eclipse.jdt.ls installation directory.")
  return
end

local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "jdtls-workspace", project_id(root_dir))
vim.fn.mkdir(workspace_dir, "p")
if not directory(workspace_dir) then
  notify(("Failed to create jdtls workspace directory: %s"):format(workspace_dir))
  return
end

local cmd = resolve_jdtls_cmd(jdtls_home, workspace_dir)
if not cmd then
  return
end

local lsp_common = require("config.lsp-common")

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  on_attach = lsp_common.on_attach,
  capabilities = lsp_common.capabilities,
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = "automatic",
      },
      inlayHints = {
        parameterNames = {
          enabled = "all",
          suppressWhenSameNameNumbered = true,
          exclusions = {},
        },
        variableTypes = {
          enabled = true,
        },
        parameterTypes = {
          enabled = true,
        },
        formatParameters = {
          enabled = true,
        },
      },
      import = {
        gradle = {
          enabled = true,
          wrapper = {
            enabled = true,
          },
        },
      },
    },
  },
  init_options = {
    bundles = {},
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
  },
})
