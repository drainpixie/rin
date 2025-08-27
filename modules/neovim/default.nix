{
  config,
  lib,
  pkgs,
  ...
}: {
  options.my.neovim = lib.mkEnableOption "faye's neovim configuration";

  config = lib.mkIf config.my.neovim {
    hm.home.packages = [(pkgs.callPackage ./neovim.nix {})];
  };
}
