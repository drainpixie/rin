{
  config,
  tools,
  lib,
  ...
}: let
  cfg = config.rin.services.umami;
  inherit (lib) mkIf mkOption types;
in {
  options.rin.services.umami = tools.mkServiceOption "umami" {
    port = 3003;
    user = "umami";
    group = "umami";
    domain = "stat.drainpixie.xyz";

    extraConfig.secretFile = mkOption {
      type = types.path;
      description = "Path to umami secret file";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = {};

    services.umami = {
      enable = true;
      createPostgresqlDatabase = true;

      settings = {
        PORT = cfg.port;
        HOSTNAME = cfg.host;
        APP_SECRET_FILE =
          if cfg.secretFile != null
          then cfg.secretFile
          else throw "umami.secretFile must be set when enabling umami service";

        TRACKER_SCRIPT_NAME = ["catz_r_cool.meow.js"];
      };
    };

    services.nginx.virtualHosts."${cfg.domain}".locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://${cfg.host}:${toString cfg.port}/";
    };
  };
}
