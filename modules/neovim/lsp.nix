{
  config,
  tools,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.neovim;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    hm.home.packages = [pkgs.nil];

    programs.nixvim = {
      lsp.inlayHints.enable = true;
      diagnostic.settings = {
        virtual_text = false;
        virtual_lines.current_line = true;
      };

      plugins = {
        lsp = {
          enable = mkIf (!cfg.minimal) true;

          servers =
            {
              rust_analyzer = {
                enable = true;

                installRustc = false;
                installCargo = false;
              };
            }
            // tools.setMany {enable = true;} [
              "cmake"
              "ts_ls"
              "svelte"
              "nil_ls"
              "gopls"
              "lua_ls"
              "clangd"
              "pyright"
            ];
        };

        conform-nvim = {
          enable = mkIf (!cfg.minimal) true;

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
                go = ["gofmt"];
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
