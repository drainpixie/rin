{
  config,
  tools,
  lib,
  ...
}: {
  config = lib.mkIf config.my.neovim.enable {
    programs.nixvim = {
      extraConfigLua = builtins.readFile ./cmp.lua;

      plugins =
        tools.enableMany
        ["luasnip" "cmp-nvim-lsp" "cmp-buffer" "cmp-path" "cmp_luasnip" "cmp-cmdline" "cmp-emoji" "copilot-cmp"]
        // {
          copilot-lua = {
            enable = true;
            settings = {
              suggestion.enabled = false;
              panel.enabled = false;
            };
          };

          lspkind = {
            enable = true;
            settings.mode = "symbol";
          };

          cmp = {
            enable = true;

            settings = {
              performance = {
                debounce = 60;
                fetchingTimeout = 200;
                maxViewEntries = 30;
              };

              autoEnableSources = true;
              snippet.expand = "luasnip";
              experimental.ghost_text = true;
              formatting.fields = ["kind" "abbr" "menu"];

              window = {
                completion = {
                  border = "rounded";
                  winhighlight = "Normal:Normal,FloatBorder:Normal";
                };

                documentation = {
                  border = "rounded";
                  winhighlight = "Normal:Normal,FloatBorder:Normal";
                };
              };

              sources = [
                {name = "nvim_lsp";}
                {name = "emoji";}
                {
                  name = "buffer";
                  option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
                  keywordLength = 3;
                }
                {name = "copilot";}
                {
                  name = "path";
                  keywordLength = 3;
                }
                {
                  name = "luasnip";
                  keywordLength = 3;
                }
              ];

              mapping = {
                "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                "<C-j>" = "cmp.mapping.select_next_item()";
                "<C-k>" = "cmp.mapping.select_prev_item()";
                "<C-e>" = "cmp.mapping.abort()";
                "<C-b>" = "cmp.mapping.scroll_docs(-4)";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";
                "<C-Space>" = "cmp.mapping.complete()";
                "<CR>" = "cmp.mapping.confirm({ select = true })";
                "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
              };
            };
          };
        };
    };
  };
}
