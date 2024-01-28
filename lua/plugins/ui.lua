-- if true then return {} end -- REMOVE THIS LINE TO ACTIVATE THIS FILE

-- ---@type LazySpec
-- return {
--   "AstroNvim/astroui",
--   ---@type AstroUIOpts
--   opts = {
--     icons = {
--       -- configure the loading of the lsp in the status line
--       LSPLoading1 = "⠋",
--       LSPLoading2 = "⠙",
--       LSPLoading3 = "⠹",
--       LSPLoading4 = "⠸",
--       LSPLoading5 = "⠼",
--       LSPLoading6 = "⠴",
--       LSPLoading7 = "⠦",
--       LSPLoading8 = "⠧",
--       LSPLoading9 = "⠇",
--       LSPLoading10 = "⠏",
--     },
--     text_icons = {
--       -- configure the loading of the lsp in the status line
--       LSPLoading1 = "|",
--       LSPLoading2 = "/",
--       LSPLoading3 = "-",
--       LSPLoading4 = "\\",

--       -- configure neotree
--       FolderClosed = "+",
--       FolderEmpty = "-",
--       FolderOpen = "-",
--     },
--   },
-- }

-- See more info at https://github.com/AstroNvim/astroui
---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    status = {
      colors = {
        -- To match up with gruvbox
        -- https://github.com/ellisonleao/gruvbox.nvim/blob/4176b0b720db0c90ab4030e5c1b4893faf41fd51/lua/gruvbox.lua#L90
        -- insert = "#fe8019",
        -- normal = "#83a598",
        insert = "#D08770",
        normal = "#5E81AC",
        visual = "#d3869b",
      },
    }
  },
}
