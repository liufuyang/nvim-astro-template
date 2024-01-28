-- if true then return {} end -- REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings set up as well as which-key menu titles
---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs with `H` and `L`
        -- L = {
        --   function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
        --   desc = "Next buffer",
        -- },
        -- H = {
        --   function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
        --   desc = "Previous buffer",
        -- },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        ["<Leader>s"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        ["<Leader>w"] = {
          function()
            vim.cmd("write!")
            require("astrocore.buffer").close()
          end,
          desc = "Save and Close Buffer" 
        },
        ["<Leader><space>"] = {
          function() require("telescope.builtin").find_files() end,
          desc = "Find files"
        },
        ["<Leader>F"] = {
          function() require("telescope.builtin").live_grep() end,
          desc = "Find words"
        },
        ["<Leader>1"] = { "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer" },
        -- Hide some short keys
        ["<Leader>C"] = false,
        ["<Leader>e"] = false, -- used to be Toggle Explorer

      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
    },
  },
}
