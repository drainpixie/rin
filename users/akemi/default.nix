{pkgs, ...}: {
  imports = [
    ./terminal.nix
    ./desktop.nix

    ../../common/neovim
    ../../common/cli.nix
    ../../common/home.nix
    ../../common/vscode.nix
    ../../common/minecraft.nix
  ];

  home = let
    username = "akemi";
  in {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = builtins.attrValues {
      inherit
        (pkgs)
        man-pages-posix
        man-pages
        ;
    };
  };

  services.arrpc.enable = true;

  xdg = {
    enable = true;

    userDirs = {
      enable = true;

      music = "$HOME/msc";
      videos = "$HOME/vid";
      desktop = "$HOME/dsk";
      download = "$HOME/dwl";
      pictures = "$HOME/img";
      documents = "$HOME/doc";
    };

    portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals = builtins.attrValues {
        inherit
          (pkgs)
          xdg-desktop-portal-gtk
          ;
      };

      configPackages = builtins.attrValues {
        inherit
          (pkgs)
          xdg-desktop-portal-gtk
          xdg-desktop-portal
          ;
      };
    };
  };
}
