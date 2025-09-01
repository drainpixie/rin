# note: we use a selfhosted wakaapi instance because the official one is sucky
# and very paywalled :(
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.my.neovim.enable && !config.my.neovim.minimal) {
    programs.nixvim.plugins.wakatime.enable = true;

    age.secrets = {
      waka-salt = {
        file = ../../secrets/wakapi-salt;
        owner = "wakapi";
        group = "wakapi";
      };

      waka-conf = {
        path = "${config.hm.home.homeDirectory}/.wakatime.cfg";
        file = ../../secrets/wakapi-conf;
        owner = config.my.user;
        group = "users";
        mode = "777"; # todo: review perms
      };
    };

    services.wakapi = {
      passwordSaltFile = config.age.secrets.waka-salt.path;

      enable = true;
      database.createLocally = true;

      settings = {
        server.port = 6969;
        security.allow_signup = false;

        db = {
          port = 5432;
          host = "127.0.0.1";
          user = "wakapi";
          name = "wakapi";
          dialect = "postgres";
        };
      };
    };
  };
}
