# credit @ getchoo/borealis
{
  lib,
  tools,
  config,
  ...
}: let
  cfg = config.rin.services.nginx;
  inherit (lib) mkIf mkOption mkDefault types;
in {
  options = {
    services.nginx.virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          config = {
            forceSSL = mkDefault true;
            enableACME = mkDefault true;
          };
        }
      );
    };

    rin.services.nginx = tools.mkServiceOption "nginx" {
      domain = "drainpixie.xyz";
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "faye.keller06+web@gmail.com";
    };

    users.users.nginx.extraGroups = ["acme"];

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      appendHttpConfig = ''
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
      '';
    };

    systemd.services.nginx.serviceConfig.ProtectHome = false;
  };
}
