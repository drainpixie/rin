{
  config,
  lib,
  pkgs,
  ...
}: {
  options.my.neovim = lib.mkEnableOption "Faye’s neovim configuration";

  config = lib.mkIf config.my.neovim {
    hm.home.packages = [(callPackage ./neovim.nix {inherit pkgs;})];
  };
}
