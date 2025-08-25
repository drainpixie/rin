{
  config,
  pkgs,
  lib,
  ...
}: let
  gnome = import ./gnome.nix {inherit config pkgs lib;};
  # berry = import ./berry.nix {inherit config pkgs lib;};
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
      security.rtkit.enable = true;

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

        pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
          jack.enable = true;
        };

        displayManager.ly.enable = true;
      };

      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            padding = {
              x = 16;
              y = 16;
            };
          };

          font = {
            normal.family = "Drafting Mono ExtraLight";
            size = 10;
          };

          keyboard = {
            bindings = [
              {
                key = "C";
                mods = "Control|Shift";
                action = "Copy";
              }
              {
                key = "V";
                mods = "Control|Shift";
                action = "Paste";
              }
            ];
          };

          # todo: split theme in module
          colors = {
            primary = {
              background = "0xf7f7f7";
              foreground = "0x000000";
            };

            normal = {
              black = "0x282a2e";
              red = "0xaa3731";
              green = "0x448c27";
              yellow = "0xcb9000";
              blue = "0x325cc0";
              magenta = "0x7a3e9d";
              cyan = "0x0083b2";
              white = "0x707880";
            };

            bright = {
              black = "0x373b41";
              red = "0xf05050";
              green = "0x60cb00";
              yellow = "0xffbc5d";
              blue = "0x007acc";
              magenta = "0xe64ce6";
              cyan = "0x00aacb";
              white = "0xc5c8c6";
            };
          };
        };
      };
    }

    (lib.mkIf (config.my.de == "gnome") gnome)
  ];
}
