{
  config,
  tools,
  lib,
  ...
}: let
  cfg = config.rin.services.wakapi;
  inherit (lib) mkIf mkOption types;
in {
  options.rin.services.wakapi = tools.mkServiceOption "wakapi" {
    port = 3002;
    user = "wakapi";
    group = "wakapi";
    domain = "waka.drainpixie.xyz";

    extraConfig.saltPath = mkOption {
      type = types.path;
      description = "Path to wakapi salt file";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    services.wakapi = {
      passwordSaltFile =
        if cfg.saltPath != null
        then cfg.saltPath
        else throw "wakapi.saltPath must be set when enabling wakapi service";

      enable = true;
      database.createLocally = true;

      settings = {
        quick_start = true;
        security.allow_signup = false;

        app.leaderboard_enabled = false;
        mail.enabled = false;

        server = {
          inherit (cfg) port;
          listen_ipv4 = cfg.host;
          base_path = "/";
          listen_ipv6 = "";
        };

        db = {
          inherit (cfg) host user;
          port = 5432;
          name = cfg.user;
          dialect = "postgres";
        };
      };
    };

    services.nginx.virtualHosts."${cfg.domain}".locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://${cfg.host}:${toString cfg.port}/";
    };
  };
}
