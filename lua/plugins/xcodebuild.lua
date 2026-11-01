-- xcodebuild.nvim: build, run, test and debug Xcode projects from Neovim.
-- Docs: https://github.com/wojciech-kulik/xcodebuild.nvim/wiki  (:h xcodebuild)
--
-- First time in a project: open nvim in the project root and run :XcodebuildSetup
-- (pick project, scheme, config, simulator). It also writes buildServer.json for the LSP.

local function xcodebuild_device()
  if vim.g.xcodebuild_platform == "macOS" then
    return " macOS"
  end
  if vim.g.xcodebuild_os then
    return " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
  end
  return " " .. vim.g.xcodebuild_device_name
end

return {
  {
    "wojciech-kulik/xcodebuild.nvim",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim", -- picker + image previews
      "MunifTanjim/nui.nvim", -- code coverage report
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("xcodebuild").setup({
        show_build_progress_bar = true,
        logs = {
          auto_open_on_success_tests = false,
          auto_open_on_failed_tests = false,
          auto_open_on_success_build = false,
          auto_open_on_failed_build = false, -- errors go to Trouble (see autocmd below)
          auto_focus = false,
          auto_close_on_app_launch = true,
          only_summary = true,
        },
        code_coverage = { enabled = true },
        integrations = {
          -- debugging on a physical iOS 17+ device needs pymobiledevice3, see README.md
          pymobiledevice = { enabled = false },
        },
      })

      -- lldb-dap from Xcode 16+ (no codelldb needed); restores saved breakpoints
      require("xcodebuild.integrations.dap").setup()

      -- show build/test errors in Trouble, close it again on success
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("xcodebuild-trouble", { clear = true }),
        pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
        callback = function(event)
          if event.data.cancelled then
            return
          end
          local trouble = require("trouble")
          if event.data.success then
            trouble.close("qflist")
          elseif not event.data.failedCount or event.data.failedCount > 0 then
            if next(vim.fn.getqflist()) then
              trouble.open("qflist")
            else
              trouble.close("qflist")
            end
          end
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      -- <leader>i = iOS / Xcode (LazyVim already uses <leader>x for diagnostics)
      { "<leader>X", "<cmd>XcodebuildPicker<cr>", desc = "Xcodebuild Actions" },
      { "<leader>iS", "<cmd>XcodebuildSetup<cr>", desc = "Setup Project" },
      { "<leader>ib", "<cmd>XcodebuildBuild<cr>", desc = "Build" },
      { "<leader>iB", "<cmd>XcodebuildBuildForTesting<cr>", desc = "Build For Testing" },
      { "<leader>ir", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run" },
      { "<leader>iR", "<cmd>XcodebuildRun<cr>", desc = "Run Without Building" },
      { "<leader>is", "<cmd>XcodebuildCancel<cr>", desc = "Stop / Cancel" },
      { "<leader>iK", "<cmd>XcodebuildCleanBuild<cr>", desc = "Clean Build" },
      { "<leader>it", "<cmd>XcodebuildTest<cr>", desc = "Run Tests" },
      { "<leader>it", "<cmd>XcodebuildTestSelected<cr>", mode = "v", desc = "Run Selected Tests" },
      { "<leader>iT", "<cmd>XcodebuildTestClass<cr>", desc = "Run Test Class" },
      { "<leader>i.", "<cmd>XcodebuildTestRepeat<cr>", desc = "Repeat Last Test Run" },
      { "<leader>ie", "<cmd>XcodebuildTestExplorerToggle<cr>", desc = "Test Explorer" },
      { "<leader>il", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Build Logs" },
      { "<leader>ic", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle Code Coverage" },
      { "<leader>iC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", desc = "Code Coverage Report" },
      { "<leader>id", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device" },
      { "<leader>ip", "<cmd>XcodebuildSelectScheme<cr>", desc = "Select Scheme" },
      { "<leader>iP", "<cmd>XcodebuildPreviewGenerateAndShow<cr>", desc = "SwiftUI Preview" },
      { "<leader>ix", "<cmd>XcodebuildQuickfixLine<cr>", desc = "Quickfix Line" },
      { "<leader>ia", "<cmd>XcodebuildCodeActions<cr>", desc = "Code Actions" },
      { "<leader>if", "<cmd>XcodebuildProjectManager<cr>", desc = "Project Manager" },
      { "<leader>io", "<cmd>XcodebuildOpenInXcode<cr>", desc = "Open in Xcode" },

      -- debugging (rest of <leader>d comes from LazyVim's dap.core extra)
      { "<leader>dd", function() require("xcodebuild.integrations.dap").build_and_debug() end, desc = "Build & Debug (Xcode)" },
      { "<leader>dD", function() require("xcodebuild.integrations.dap").debug_without_build() end, desc = "Debug Without Building (Xcode)" },
      { "<leader>dT", function() require("xcodebuild.integrations.dap").debug_tests() end, desc = "Debug Tests (Xcode)" },
      { "<leader>dX", function() require("xcodebuild.integrations.dap").terminate_session() end, desc = "Terminate Debug Session (Xcode)" },
      { "<leader>db", function() require("xcodebuild.integrations.dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (saved)" },
      { "<leader>dm", function() require("xcodebuild.integrations.dap").toggle_message_breakpoint() end, desc = "Toggle Log Breakpoint" },
    },
  },

  -- which-key group label
  {
    "folke/which-key.nvim",
    opts = {
      spec = { { "<leader>i", group = "iOS / Xcode", icon = { icon = " ", color = "azure" } } },
    },
  },

  -- statusline: last build status, test plan and selected simulator
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        xcodebuild_device,
        cond = function()
          return vim.g.xcodebuild_device_name ~= nil
        end,
      })
      table.insert(opts.sections.lualine_x, 1, {
        function()
          return " " .. vim.g.xcodebuild_last_status
        end,
        cond = function()
          return vim.g.xcodebuild_last_status ~= nil and vim.g.xcodebuild_last_status ~= ""
        end,
      })
    end,
  },
}
