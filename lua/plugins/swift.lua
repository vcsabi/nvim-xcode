-- Swift language support: syntax highlighting, LSP (autocomplete), lint, format.
return {
  -- syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },

  -- LSP: sourcekit-lsp ships with Xcode. It understands .xcodeproj only through
  -- xcode-build-server (buildServer.json in the project root, created by :XcodebuildSetup).
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false, -- provided by Xcode, not mason
          cmd = { "xcrun", "sourcekit-lsp" },
          filetypes = { "swift", "objc", "objcpp" },
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },
      },
    },
  },

  -- lint: swiftlint (brew install swiftlint)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { swift = { "swiftlint" } },
    },
  },

  -- format: swiftformat (brew install swiftformat)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { swift = { "swiftformat" } },
    },
  },
}
