-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- reload buffers changed on disk (Xcode, swiftformat, hot reload previews)
vim.opt.autoread = true

-- Don't run swiftformat on every save by default: the project has no .swiftformat
-- config yet, so it would reformat whole files. Toggle with <leader>uf, or format
-- on demand with <leader>cf.
vim.g.autoformat = false
