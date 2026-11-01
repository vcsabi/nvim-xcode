-- nvim-xcode: LazyVim-based config for iOS/Swift development (xcodebuild.nvim).
-- Launch with: NVIM_APPNAME=nvim-xcode nvim

-- xcode-select may point at CommandLineTools, which has no xcodebuild/simctl.
-- Point this Neovim (and everything it spawns: sourcekit-lsp, xcode-build-server,
-- lldb-dap) at the full Xcode without touching the system-wide setting.
if not vim.env.DEVELOPER_DIR then
  local selected = vim.trim(vim.fn.system({ "xcode-select", "-p" }))
  local xcode = "/Applications/Xcode.app/Contents/Developer"
  if selected:find("CommandLineTools", 1, true) and vim.uv.fs_stat(xcode) then
    vim.env.DEVELOPER_DIR = xcode
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
