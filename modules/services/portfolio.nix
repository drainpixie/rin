{
  inputs,
  config,
  tools,
  pkgs,
  lib,
  ...
}: let
  cfg = config.rin.services.portfolio;
  portfolio = inputs.portfolio.lib.${pkgs.stdenv.hostPlatform.system};
  inherit (lib) mkIf;
in {
  options.rin.services.portfolio = tools.mkServiceOption "portfolio" {
    port = 3000;
    domain = "drainpixie.xyz";
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = {};

    systemd.services.portfolio = {
      description = "my portfolio";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = let
        site =
          (portfolio.withEnv {
            KUMA_URL = "https://kuma.drainpixie.xyz";
            KUMA_SLUG = "rin";
            NODE_ENV = "production";
            PORT = toString cfg.port;
          }).outPath;
      in {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";

        WorkingDirectory = site;

        ExecStart = "${pkgs.nodejs_24}/bin/node ${site}/server.js";
      };
    };

    services.nginx.virtualHosts."${cfg.domain}".locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}/";
  };
}
