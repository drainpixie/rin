{config, ...}: {
  imports = [
    ../../modules/neovim
    ../../modules/shell.nix
    ../../modules/services/drainpixie.nix

    ./nginx.nix
    ./wakapi.nix
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

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  programs.ssh.startAgent = true;

  time.hardwareClockInLocalTime = true;
  documentation.nixos.enable = false;

  services = {
    drainpixie.enable = true;

    chrony.enable = true;

    journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=1month
    '';

    openssh = {
      enable = true;
      settings = {
        Protocol = 2;
        MaxAuthTries = 3;
        PermitRootLogin = "no";
        X11Forwarding = false;
        ClientAliveCountMax = 2;
        ClientAliveInterval = 300;
        PasswordAuthentication = false;
      };
      ports = [2222];
      allowSFTP = false;
    };

    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      bantime-increment.enable = true;
    };
  };

  users.users.root.hashedPassword = "!";
  users.users.${config.my.user} = {
    description = "faye's user";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjrd3Drz463j6IpRJzPIm+KczyhYE7upw7rjlGTlMnJ"];
  };

  security = {
    sudo.enable = true;
    audit.enable = true;
    auditd.enable = true;
    pam = {
      sshAgentAuth.enable = true;
      services.sudo.sshAgentAuth = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [2222 80 443];
    allowedUDPPorts = [];
    logRefusedConnections = true;
  };

  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    allowReboot = false;
    randomizedDelaySec = "45min";
    flags = ["--update-input" "nixpkgs"];
    flake = "github:drainpixie/rin#incubator";
  };
}
