{pkgs, ...}: {
  systemd.user.startServices = "sd-switch";

  home = {
    packages = let
      minecraft = pkgs.prismlauncher.override {
        jdks = builtins.attrValues {
          inherit (pkgs) temurin-bin-21 temurin-bin-17 temurin-bin-8;
        };
      };

      # todo: declarative, we use settingssync right now
      insiders = (pkgs.vscode.override {isInsiders = true;}).overrideAttrs (oldAttrs: {
        src = fetchTarball {
          url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
          sha256 = "06lvxcd01idv6y6305qwq0n6vn942z9lfs526nd83vp35jasayv4";
        };

        version = "latest";
        buildInputs = oldAttrs.buildInputs ++ [pkgs.krb5];
      });
    in
      builtins.attrValues {
        # cli
        inherit
          (pkgs)
          man-pages
          man-pages-posix
          wl-clipboard
          xclip
          xsel
          du-dust
          strace
          tokei
          wget
          curl
          fd
          jq
          ;

        # apps
        inherit
          (pkgs)
          telegram-desktop
          signal-desktop
          google-chrome
          pavucontrol
          zathura
          vesktop
          gparted
          bruno
          nsxiv
          mpv
          ;

        # fonts
        inherit (pkgs) meslo-lgs-nf;
        inherit (pkgs.faye) drafting-mono beedii azuki;
      }
      ++ [
        minecraft
        insiders.fhs
      ];
  };

  xdg = {
    userDirs = {
      enable = true;

      music = "$HOME/msc";
      videos = "$HOME/vid";
      desktop = "$HOME/dsk";
      download = "$HOME/dwl";
      pictures = "$HOME/img";
      documents = "$HOME/doc";
    };

    mimeApps.defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "text/plain" = "code.desktop";

      "application/pdf" = "zathura.desktop";
      "application/epub+zip" = "zathura.desktop";

      "image/*" = "nsxiv.desktop";
      "video/*" = "mpv.desktop";
    };
  };
}
