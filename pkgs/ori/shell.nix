{pkgs ? import <nixpkgs> {}}: let
  ori = pkgs.vimUtils.buildVimPlugin {
    name = "ori";
    src = ./.;
  };
in
  pkgs.mkShell {
    shellHook = ''
      export PLUGIN_PATH=${ori}
      echo "Plugin built at: $PLUGIN_PATH"
      echo "Add to your Neovim config:"
      echo "vim.opt.rtp:prepend('${ori}')"
      echo "or run the command"
      echo ":set rtp^=${ori}"
    '';
  }
