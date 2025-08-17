{
  lib,
  opts,
  ...
}: {
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "The username for the host configuration.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "hostname";
      description = "The hostname for the host configuration.";
    };

    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "The default editor for the host configuration.";
    };

    architecture = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
      description = "The architecture for the host configuration.";
    };
  };

  config = {
    networking.hostName = opts.host;

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Rome";
  };
}
