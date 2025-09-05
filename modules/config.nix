{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  options.my = {
    git = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "User Name";
        description = "The name for the git user.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "at@noreply.me";
        description = "The email for the git user.";
      };
    };

    age = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable age support.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "The username for the host configuration.";
    };

    docker = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Docker support.";
    };

    bluetooth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Bluetooth support.";
    };

    vm = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable VM support (mostly for testing).";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "hostname";
      description = "The hostname for the host configuration.";
    };

    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "The default editor.";
    };

    architecture = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
      description = "The architecture.";
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = _: true;

    fonts.fontconfig.enable = true;
    networking.hostName = config.my.host;

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Rome";

    users.users.${config.my.user} = {
      uid = 1000;
      isNormalUser = true;
      home = "/home/${config.my.user}";
      initialPassword = "changeme";
      extraGroups = ["wheel" "audio" "video"] ++ lib.optionals config.my.docker ["docker"];
    };

    hardware.bluetooth = lib.mkIf config.my.bluetooth {
      enable = true;
      powerOnBoot = true;
    };

    virtualisation = lib.mkMerge [
      (lib.mkIf config.my.vm {
        vmVariant.virtualisation = {
          graphics = true;
          cores = 4;
          memorySize = 4 * 1024;
        };
      })

      (lib.mkIf config.my.docker {
        docker = {
          enable = true;
        };
      })
    ];

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        warn-dirty = false;
        trusted-users = [config.my.user];
      };
      gc = {
        automatic = true;
        dates = "monthly";
        options = "--delete-older-than 30d";
      };
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = "it";
    };

    hm = {
      programs = {
        home-manager.enable = true;
        git = {
          enable = true;

          extraConfig = {
            color.ui = "auto";
            pull.rebase = true;
            delta.enable = true;
            init.defaultBranch = "main";

            core.editor = config.my.editor;
          };

          userName = config.my.git.user;
          userEmail = config.my.git.email;
        };
      };

      home = {
        homeDirectory = "/home/${config.my.user}";

        sessionVariables = {
          EDITOR = config.my.editor;
          MANPAGER = lib.mkIf (config.my.editor == "nvim") "nvim +Man!";
        };

        packages = lib.mkMerge [
          (lib.mkIf config.my.docker [pkgs.docker pkgs.docker-compose])
          (lib.mkIf config.my.age [inputs.age.packages.${config.my.architecture}.default])
        ];
      };
    };
  };
}
