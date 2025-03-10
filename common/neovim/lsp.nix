_: {
  programs.nixvim.plugins = {
    lsp-format.enable = true;

    lsp = {
      enable = true;

      servers = {
        cmake.enable = true;
        ts_ls.enable = true;
        svelte.enable = true;
        nil_ls.enable = true;
        clangd.enable = true;
        pyright.enable = true;

        rust_analyzer = {
          enable = true;

          installRustc = false;
          installCargo = false;
        };
      };
    };

    none-ls = {
      enable = true;
      enableLspFormat = true;
      settings.update_in_insert = false;

      sources = {
        code_actions = {
          gitsigns.enable = true;
          statix.enable = true;
        };

        diagnostics = {
          statix.enable = true;
        };

        formatting = {
          black.enable = true;
          just.enable = true;
          alejandra.enable = true;
          clang_format.enable = true;

          prettier = {
            enable = true;
            disableTsServerFormatter = true;
          };

          stylua.enable = true;
        };
      };
    };

    conform-nvim = {
      enable = true;

      settings = {
        format_on_save = {
          lspFallback = true;
          timeoutMs = 2000;
        };

        notify_on_error = true;

        formatters_by_ft =
          {
            python = ["black"];
            lua = ["stylua"];
            nix = ["alejandra"];
            rust = ["rustfmt"];
            just = ["just"];
          }
          // builtins.listToAttrs (map (ft: {
              name = ft;
              value = {
                __unkeyed-1 = "biome";
                __unkeyed-2 = "prettierd";
                __unkeyed-3 = "prettier";

                stop_after_first = true;
              };
            })
            ["html" "css" "javascript" "javascriptreact" "typescript" "typescriptreact" "markdown"]);
      };
    };
  };
}
