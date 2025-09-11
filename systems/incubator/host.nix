{config, ...}: {
  imports = [
    ../../modules/neovim
    ../../modules/shell.nix

    ./nginx.nix
  ];

  my = {
    shell = {
      enable = true;
      minimal = true;
    };

    neovim = {
      enable = true;
      minimal = true;
    };

    vm = true;
    age = true;
  };

  age.identityPaths = ["${config.hm.home.homeDirectory}/.ssh/drainpixie"];
  programs.ssh.startAgent = true;

  time.hardwareClockInLocalTime = true;
  documentation.nixos.enable = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.${config.my.user} = {
    description = "faye's user";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjrd3Drz463j6IpRJzPIm+KczyhYE7upw7rjlGTlMnJ"];
  };

  security.sudo.enable = true;
  security.pam = {
    sshAgentAuth.enable = true;
    services.sudo.sshAgentAuth = true;
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [22 80];
    };
  };

  virtualisation.vmVariant.virtualisation.forwardPorts = [
    {
      from = "host";
      guest.port = 80;
      host.port = 8080;
    }
  ];
}
