-- return {
--   "folke/snacks.nvim",
--   opts = {
--     picker = {
--       sources = {
--         explorer = { hidden = true },
--       },
--     },
--   },
-- }

return {
  "folke/snacks.nvim",
  opts = {
    -- Defaults for picker UI (some parts inherit these)
    picker = {
      hidden = true,
      ignored = true,

      -- Force it specifically for explorer (and optionally other sources)
      sources = {
        explorer = { hidden = true, ignored = true },
        files = { hidden = true, ignored = true },
        grep = { hidden = true, ignored = true },
      },
    },
  },
}
