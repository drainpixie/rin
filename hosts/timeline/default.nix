{pkgs, ...}: {
  imports = [
    ./steam.nix
    ./audio.nix
    ./xserver.nix
    ./hardware.nix

    ../../common/system.nix
  ];

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      ntfs3g
      docker-compose
      ;
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };

  networking.hostName = "timeline";
  powerManagement.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  services = {
    tailscale.enable = true;
    upower.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix.settings.trusted-users = ["akemi"];
  users.users.akemi = {
    uid = 1000;
    home = "/home/akemi";

    shell = pkgs.bash;
    isNormalUser = true;
    initialPassword = "changeme";

    extraGroups = [
      "wheel"
      "audio"
      "docker"
      "networkmanager"
    ];
  };

  system.stateVersion = "23.11";
}
