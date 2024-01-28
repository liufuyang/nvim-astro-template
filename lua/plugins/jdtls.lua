-- copy from community pack

return {
  {
    -- better way of setting dap with remote debug configurations
    "mfussenegger/nvim-dap",
    optional = true,
    config = function ()
      local dap = require "dap"
      local java_config = {
        {
          type = "java",
          request = "attach",
          name = "Attach debugger to remote",
          hostName = function ()
            local host = vim.fn.input('Attach to host [127.0.0.1]: ')
            host = host ~= '' and host or '127.0.0.1'
            return host
          end,
          port = function ()
            local port = tonumber(vim.fn.input('On port [4100]: ')) or 4100
            return port
          end
        },
        {
          type = "java",
          request = "attach",
          name = "Attach debugger to localhost on 4100",
          hostName = '127.0.0.1',
          port = 4100,
        },
        {
          type = "java",
          request = "attach",
          name = "Attach debugger to localhost on 4200",
          hostName = '127.0.0.1',
          port = 4200,
        },
        {
          type = "java",
          request = "attach",
          name = "Attach debugger to localhost on 4300",
          hostName = '127.0.0.1',
          port = 4300,
        },
      }
      dap.configurations.java = dap.configurations.java and vim.list_extend(dap.configurations.java, java_config)
        or java_config
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, "java", "html")
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, "jdtls", "lemminx")
    end,
  },

  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, "clang_format")
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, "javadbg", "javatest")
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      {
        "AstroNvim/astrolsp",
        ---@type AstroLSPOpts
        opts = {
          ---@diagnostic disable: missing-fields
          handlers = { jdtls = false },
        },
      },
    },
    opts = function(_, opts)
      local utils = require "astrocore"
      -- use this function notation to build some variables
      local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      -- calculate workspace dir
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
      vim.fn.mkdir(workspace_dir, "p")

      -- validate operating system
      if not (vim.fn.has "mac" == 1 or vim.fn.has "unix" == 1 or vim.fn.has "win32" == 1) then
        utils.notify("jdtls: Could not detect valid OS", vim.log.levels.ERROR)
      end

      return utils.extend_tbl({
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Djava.import.generatesMetadataFilesAtProjectRoot=false", -- https://github.com/redhat-developer/vscode-java/blob/master/document/_java.metadataFilesGeneration.md
          "-javaagent:" .. vim.fn.expand "$MASON/share/jdtls/lombok.jar",
          "-Xms1g",
          "-Xms8g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          vim.fn.expand "$MASON/share/jdtls/plugins/org.eclipse.equinox.launcher.jar",
          "-configuration",
          vim.fn.expand "$MASON/share/jdtls/config",
          "-data",
          workspace_dir,
        },
        root_dir = root_dir,
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
        init_options = {
          bundles = {
            vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
            -- unpack remaining bundles
            (table.unpack or unpack)(vim.split(vim.fn.glob "$MASON/share/java-test/*.jar", "\n", {})),
          },
        },
        handlers = {
          ["$/progress"] = function() end, -- disable progress updates.
        },
        filetypes = { "java" },
        on_attach = function(client, bufnr)
          require("jdtls").setup_dap { hotcodereplace = "auto" }
          require("astrolsp").on_attach(client, bufnr)

          -- format modification only instead of whole file setup
          -- this setup the format modification on save
          -- https://github.com/joechrisellis/lsp-format-modifications.nvim
          local augroup_id = vim.api.nvim_create_augroup(
            "FormatModificationsDocumentFormattingGroup",
            { clear = false }
          )
          vim.api.nvim_clear_autocmds({ group = augroup_id, buffer = bufnr })
          vim.api.nvim_create_autocmd(
            { "BufWritePre" },
            {
              group = augroup_id,
              buffer = bufnr,
              callback = function()
                local lsp_format_modifications = require"lsp-format-modifications"
                lsp_format_modifications.format_modifications(client, bufnr)
              end,
            }
          )
          -- one can also turn off the on save trigger above and use this user command instead
          vim.api.nvim_buf_create_user_command(
            bufnr,
            "FormatModifications",
            function()
              local lsp_format_modifications = require"lsp-format-modifications"
              lsp_format_modifications.format_modifications(client, bufnr)
            end,
            {}
          )
          -- end of format modifcation on save setup
        end,
      }, opts)
    end,
    config = function(_, opts)
      -- setup autocmd on filetype detect java
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "java", -- autocmd to start jdtls
        callback = function()
          if opts.root_dir and opts.root_dir ~= "" then
            require("jdtls").start_or_attach(opts)
          else
            require("astrocore").notify("jdtls: root_dir not found. Please specify a root marker", vim.log.levels.ERROR)
          end
        end,
      })
      -- create autocmd to load main class configs on LspAttach.
      -- This ensures that the LSP is fully attached.
      -- See https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      vim.api.nvim_create_autocmd("LspAttach", {
        pattern = "*.java",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          -- ensure that only the jdtls client is activated
          if client.name == "jdtls" then require("jdtls.dap").setup_dap_main_class_configs() end
        end,
      })
    end,
  },
}