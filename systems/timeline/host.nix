{
  opts,
  pkgs,
  ...
}: {
  users.users."${opts.user}".shell = pkgs.zsh;
  programs.zsh.enable = true;

  time.hardwareClockInLocalTime = true;
  documentation.nixos.enable = false;
  services.upower.enable = true;
  powerManagement.enable = true;
  services.tlp.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.${opts.user} = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    home = "/home/${opts.user}";
    initialPassword = "changeme";
    description = "timeline's admin";

    extraGroups = [
      "wheel"
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
        core.editor = opts.editor;
      };
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      warn-dirty = false;
      trusted-users = [opts.user];
    };

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
  };

  networking = {
    networkmanager.enable = true;

    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "it";
  };
}
