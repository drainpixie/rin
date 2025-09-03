{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./cmp
    ./line

    ./lsp.nix
    ./git.nix
    ./oil.nix
    ./waka.nix
    ./telescope.nix
    ./toggleterm.nix
  ];

  options.my.neovim.enable = lib.mkEnableOption "faye's neovim configuration";
  options.my.neovim.minimal = lib.mkEnableOption "minimal neovim configuration";

  config = lib.mkIf config.my.neovim.enable {
    programs.nixvim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      defaultEditor = true;

      globals.mapleader = " ";
      colorscheme = "alabaster";

      opts = {
        number = true;
        relativenumber = true;
        termguicolors = true;

        smartindent = true;
        expandtab = true;
        softtabstop = 2;
        shiftwidth = 2;
        tabstop = 2;

        swapfile = false;
        backup = false;
        undofile = true;

        hlsearch = false;
        incsearch = true;

        autoread = true;
        lazyredraw = true;

        wrap = false;
        linebreak = true;

        modelines = 4;
        modeline = true;
        showmode = false;
        modelineexpr = true;
        background = "light";
      };

      clipboard = {
        register = "unnamedplus";

        providers = {
          wl-copy = {
            enable = true;
            package = pkgs.wl-clipboard;
          };

          xsel = {
            enable = true;
            package = pkgs.xsel;
          };

          xclip = {
            enable = true;
            package = pkgs.xclip;
          };
        };
      };

      performance.byteCompileLua = {
        enable = true;
        configs = true;
        plugins = true;
        nvimRuntime = true;
      };

      plugins = {
        neocord.enable = lib.mkIf (!config.my.neovim.minimal) true;
        undotree.enable = true;
        treesitter.enable = true;
        nvim-autopairs.enable = true;

        navic = {
          enable = lib.mkIf (!config.my.neovim.minimal) true;
          settings.lsp.auto_attach = true;
        };

        colorizer = {
          enable = lib.mkIf (!config.my.neovim.minimal) true;
          settings = {
            fileTypes = ["*"];
            user_default_options.names = false;
          };
        };
      };

      keymaps = [
        {
          action = ":noh<CR>";
          key = "<Esc>";
          mode = "n";
          options = {
            silent = true;
            desc = "Clear search highlights.";
          };
        }
        {
          action = ":%s/";
          key = "<leader>r";
          mode = "n";
          options.desc = "Easier find and replace.";
        }
        {
          action = "<C-r>";
          key = "q";
          mode = "n";
          options.desc = "Easier redo.";
        }
        {
          action = "<C-d>zz";
          key = "D";
          mode = "n";
          options.desc = "Jump half a page without moving the cursor.";
        }
        {
          action = "<C-u>zz";
          key = "U";
          mode = "n";
          options.desc = "Jump half a page without moving the cursor.";
        }
        {
          action = "<Esc>";
          key = "kk";
          mode = "i";
          options.desc = "Exit insert mode with 'kk'.";
        }
        {
          action = "<gv";
          key = "<";
          mode = "v";
          options.desc = "Indent selected lines.";
        }
        {
          action = ">gv";
          key = ">";
          mode = "v";
          options.desc = "Indent selected lines.";
        }
        {
          action = ":m '>+1<CR>gv=gv";
          key = "J";
          mode = "v";
          options.desc = "Move selected lines down.";
        }
        {
          action = ":m '<-2<CR>gv=gv";
          key = "K";
          mode = "v";
          options.desc = "Move selected lines up.";
        }
      ];

      extraPlugins = builtins.attrValues {
        inherit (pkgs.my) alabaster ori;
      };

      extraConfigLua = ''
        require('ori').setup()
      '';
    };
  };
}
