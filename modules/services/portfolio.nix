{
  inputs,
  config,
  tools,
  pkgs,
  lib,
  ...
}: let
  cfg = config.rin.services.portfolio;
  inherit (lib) mkIf;
in {
  options.rin.services.portfolio = tools.mkServiceOption "portfolio" {
    port = 3001;
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

      serviceConfig = let
        site = inputs.website.packages.${pkgs.system}.default.outPath;
      in {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";

        WorkingDirectory = site;
        ExecStart = "${pkgs.nodejs_24}/bin/node ${site}/server.js";
        Environment = [
          "NODE_ENV=production"
          "PORT=${toString cfg.port}"
        ];
      };

      wantedBy = ["multi-user.target"];
    };

    services.nginx.virtualHosts."${cfg.domain}".locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}/";
  };
}
