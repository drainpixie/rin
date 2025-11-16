# credits @ isabelroses/dotfiles
{nixpkgs, ...}: let
  inherit (nixpkgs.lib) mkEnableOption mkOption types;
in
  name: {
    port ? 0,
    host ? "127.0.0.1",
    domain ? "",
    user ? null,
    group ? null,
    extraConfig ? {},
  }:
    {
      enable = mkEnableOption "Enable the ${name} service";

      host = mkOption {
        type = types.str;
        default = host;
        description = "The host for ${name} service";
      };

      port = mkOption {
        type = types.port;
        default = port;
        description = "The port for ${name} service";
      };

      user = mkOption {
        type = types.str;
        default =
          if user != null
          then user
          else name;
        description = "The user that runs the ${name} service";
      };

      group = mkOption {
        type = types.str;
        default =
          if group != null
          then group
          else name;
        description = "The group that runs the ${name} service";
      };

      domain = mkOption {
        type = types.str;
        default = domain;
        defaultText = "networking.domain";
        description = "Domain name for the ${name} service";
      };
    }
    // extraConfig
