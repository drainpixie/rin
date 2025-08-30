{
  config,
  tools,
  lib,
  ...
}: {
  config = lib.mkIf config.my.neovim.enable {
    programs.nixvim = {
      lsp.inlayHints.enable = true;
      diagnostic.settings = {
        virtual_text = false;
        virtual_lines.current_line = true;
      };

      plugins = {
        lsp = {
          enable = lib.mkIf (!config.my.neovim.minimal) true;

          servers =
            tools.enableMany [
              "cmake"
              "ts_ls"
              "svelte"
              "nil_ls"
              "lua_ls"
              "clangd"
              "pyright"
            ]
            // {
              rust_analyzer = {
                enable = true;

                installRustc = false;
                installCargo = false;
              };
            };
        };

        conform-nvim = {
          enable = lib.mkIf (!config.my.neovim.minimal) true;

          settings = {
            format_on_save = {
              lspFallback = true;
              timeoutMs = 2000;
            };

            notify_on_error = true;

            formatters_by_ft =
              {
                python = [
                  "isort"
                  "black"
                ];
                lua = ["stylua"];
                rust = ["rustfmt"];
                c = ["clang-format"];
                cpp = ["clang-format"];
                nix = ["alejandra"];
              }
              // builtins.listToAttrs (
                map
                (ft: {
                  name = ft;
                  value = {
                    __unkeyed-1 = "prettierd";
                    __unkeyed-2 = "prettier";

                    stop_after_first = true;
                  };
                })
                [
                  "html"
                  "css"
                  "javascript"
                  "javascriptreact"
                  "typescript"
                  "typescriptreact"
                  "markdown"
                ]
              );
          };
        };
      };
    };
  };
}
