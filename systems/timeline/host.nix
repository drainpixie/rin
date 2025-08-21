{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/shell.nix
    ../../modules/de.nix
  ];

  my = {
    de = "gnome";
    layout = "it";

    shell.minimal = false;
    shell.enable = true;
  };

  time.hardwareClockInLocalTime = true;
  documentation.nixos.enable = false;
  services.upower.enable = true;
  powerManagement.enable = true;
  services.tlp.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.${config.my.user} = {
    description = "faye's user";

    extraGroups = [
      "audio"
      "video"
      "docker"
      "networkmanager"
    ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    git = {
      enable = true;

      config = {
        color.ui = "auto";
        pull.rebase = true;
        init.defaultBranch = "main";
        core.editor = config.my.editor;
      };
    };
  };

  networking = {
    networkmanager.enable = true;

    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
