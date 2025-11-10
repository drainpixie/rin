{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.drainpixie;
  inherit (lib) mkEnableOption mkOption types mkIf;
in {
  # TODO: Generalise architecture for other web apps
  options.services.drainpixie = {
    enable = mkEnableOption "my personal website";

    nodejs = mkOption {
      type = types.package;
      default = pkgs.nodejs_24;
      description = "The Node.js package to use for drainpixie.";
    };

    user = mkOption {
      type = types.str;
      default = "webapps";
      description = "The user that runs the app";
    };

    group = mkOption {
      type = types.str;
      default = "webapps";
      description = "The group that runs the app";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = {};

    systemd.services.drainpixie = let
      site = inputs.website.packages.${pkgs.system}.default.outPath;
    in {
      description = "my personal website";
      after = ["network.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";

        WorkingDirectory = site;
        ExecStart = "${cfg.nodejs}/bin/node ${site}/server.js";
        Environment = [
          "NODE_ENV=production"
          "PORT=3001"
        ];
      };

      wantedBy = ["multi-user.target"];
    };
  };
}
