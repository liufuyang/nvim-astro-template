return {
  -- https://docs.astronvim.com/recipes/cmp/#customize-keybindings
  { -- override nvim-cmp plugin
    "hrsh7th/nvim-cmp",
    -- override the options table that is used in the `require("cmp").setup()` call
    opts = function(_, opts)
      -- opts parameter is the default options table
      -- the function is lazy loaded so cmp is able to be required
      local cmp = require "cmp"
      -- modify the mapping part of the table
      -- opts.mapping["<C-x>"] = cmp.mapping.select_next_item()
      opts.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }

      -- return the new table to be used
      return opts
    end,
  },
}
