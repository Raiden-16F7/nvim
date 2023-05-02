return {
  "hrsh7th/nvim-cmp",
  version = false, -- last release is way too old
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    "onsails/lspkind.nvim",
  },
  opts = function()
    local cmp = require("cmp")
    local icons = require("utils/icons")
    local lspkind = require("lspkind")
    local has_words_before = function()
      if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
      end
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
    end
    local snip_status_ok, luasnip = pcall(require, "luasnip")
    local check_backspace = function()
      local col = vim.fn.col(".") - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
    end
    local function get_lsp_completion_context(completion, source)
      local ok, source_name = pcall(function()
        return source.source.client.config.name
      end)
      if not ok then
        return nil
      end
      if source_name == "tsserver" then
        return completion.detail
      elseif source_name == "pyright" then
        if completion.labelDetails ~= nil then
          return completion.labelDetails.description
        end
      end
    end
    local source_mapping = {
      npm = icons.terminal .. "NPM",
      cmp_tabnine = icons.light,
      nvim_lsp = icons.paragraph .. "LSP",
      buffer = icons.buffer .. "BUF",
      nvim_lua = icons.bomb,
      luasnip = icons.snippet .. "SNP",
      calc = icons.calculator,
      path = icons.folderOpen2,
      treesitter = icons.tree,
      zsh = icons.terminal .. "ZSH",
    }
    return {
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered({
          winhighlight = "Normal:NormalSB,FloatBorder:Statement,CursorLine:Label,Search:Error",
        }),
        documentation = cmp.config.window.bordered({
          winhighlight = "Normal:NormalSB,FloatBorder:Statement,CursorLine:Label,Search:Error",
        }),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<S-CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif cmp.visible() and has_words_before() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif check_backspace() then
            fallback()
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 10 },
        { name = "luasnip", priority = 7 },
        { name = "buffer", priority = 7 },
        { name = "path", priority = 4 },
        { name = "cmp-tabnine", priority = 8 },
      }),
      formatting = {
        format = function(_, item)
          -- Get the item with kind from the lspkind plugin
          local item_with_kind = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            symbol_map = source_mapping,
          })(_, item)

          item_with_kind.kind = lspkind.symbolic(item_with_kind.kind, { with_text = true })
          item_with_kind.menu = source_mapping[_.source.name]
          item_with_kind.menu = vim.trim(item_with_kind.menu or "")
          item_with_kind.abbr = string.sub(item_with_kind.abbr, 1, item_with_kind.maxwidth)

          if _.source.name == "cmp_tabnine" then
            if _.completion_item.data ~= nil and _.completion_item.data.detail ~= nil then
              item_with_kind.kind = " " .. lspkind.symbolic("Event", { with_text = false }) .. " TabNine"
              item_with_kind.menu = item_with_kind.menu .. _.completion_item.data.detail
            else
              item_with_kind.kind = " " .. lspkind.symbolic("Event", { with_text = false }) .. " TabNine"
              item_with_kind.menu = item_with_kind.menu .. " TBN"
            end
          end

          local completion_context = get_lsp_completion_context(_.completion_item, _.source)
          if completion_context ~= nil and completion_context ~= "" then
            item_with_kind.menu = item_with_kind.menu .. [[ -> ]] .. completion_context
          end

          return item_with_kind
        end,
      },
      experimental = {
        ghost_text = {
          hl_group = "LspCodeLens",
        },
      },
    }
  end,
}
