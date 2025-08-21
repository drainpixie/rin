{
  config,
  pkgs,
  lib,
  ...
}: let
  gnomeExtensions = builtins.attrValues {
    inherit
      (pkgs.gnomeExtensions)
      caffeine
      impatience
      light-style
      appindicator
      launch-new-instance
      rounded-window-corners-reborn
      ;
  };
in {
  options.my.layout = lib.mkOption {
    type = lib.types.str;
    default = "it";
    description = "The keyboard layout to use.";
  };

  options.my.de = lib.mkOption {
    type = lib.types.enum ["gnome" "berry"];
    default = "gnome";
    description = "faye's desktop environments";
  };

  config = lib.mkMerge [
    {
      services = {
        xserver = {
          enable = true;
          xkb.layout = config.my.layout;

          excludePackages = builtins.attrValues {
            inherit
              (pkgs)
              xterm
              ;
          };
        };

        displayManager.ly.enable = true;
      };
    }

    (lib.mkIf (config.my.de == "gnome") {
      programs.ssh.startAgent = lib.mkForce false;

      services = {
        desktopManager.gnome.enable = true;
        gnome.gnome-keyring.enable = true;
        gnome.gcr-ssh-agent.enable = true; # programs.ssh.startAgent conflicts
        tlp.enable = lib.mkForce false; # ditto as ssh
        power-profiles-daemon.enable = true;
      };

      environment.gnome.excludePackages = builtins.attrValues {
        inherit
          (pkgs)
          gnome-shell-extensions
          gnome-initial-setup
          gnome-text-editor
          gnome-calendar
          gnome-contacts
          gnome-console
          gnome-weather
          gnome-photos
          gnome-music
          gnome-maps
          gnome-tour
          simple-scan
          epiphany
          snapshot
          evince
          atomix
          cheese
          hitori
          gedit
          geary
          iagno
          totem
          tali
          yelp
          ;
      };

      hm = {
        home.packages = gnomeExtensions;

        xdg.portal = {
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

        dconf = {
          enable = true;

          settings = {
            "org/gnome/shell" = {
              disable-user-extensions = false;
              disabled-extensions = [];
              enabled-extensions = map (p: p.extensionUuid) gnomeExtensions;
            };

            "org/gnome/desktop/wm/keybindings" = {
              close = ["<Super>q"];
              toggle-maximized = ["<Super>m"];
              toggle-fullscreen = ["<Super>f"];

              move-to-workspace-1 = ["<Shift><Super>1"];
              move-to-workspace-2 = ["<Shift><Super>2"];
              move-to-workspace-3 = ["<Shift><Super>3"];
              move-to-workspace-4 = ["<Shift><Super>4"];
              move-to-workspace-5 = ["<Shift><Super>5"];

              switch-to-workspace-1 = ["<Super>1"];
              switch-to-workspace-2 = ["<Super>2"];
              switch-to-workspace-3 = ["<Super>3"];
              switch-to-workspace-4 = ["<Super>4"];
              switch-to-workspace-5 = ["<Super>5"];
            };

            "org/gnome/shell/keybindings" = {
              switch-to-application-1 = [];
              switch-to-application-2 = [];
              switch-to-application-3 = [];
              switch-to-application-4 = [];
              switch-to-application-5 = [];
              switch-to-application-6 = [];
              switch-to-application-7 = [];
              switch-to-application-8 = [];
              switch-to-application-9 = [];
              switch-to-application-10 = [];
            };

            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              ];
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              binding = "<Super>Return";
              command = "alacritty";
              name = "Launch terminal";
            };

            "org/gnome/desktop/interface" = {
              font-name = "Drafting Mono ExtraLight 10";
            };

            "org/gtk/gtk4/settings/file-chooser" = {
              show-hidden = true;
              sort-directories-first = true;
              view-type = "list";
            };

            "org/gtk/settings/debug".enable-inspector-keybinding = true;
          };
        };
      };
    })
  ];
}
