{config, ...}: {
  age.secrets = {
    waka-salt = {
      file = ../../secrets/wakapi-salt;
      owner = "wakapi";
      group = "wakapi";
    };
  };

  services.wakapi = {
    passwordSaltFile = config.age.secrets.waka-salt.path;

    enable = true;
    database.createLocally = true;

    settings = {
      quick_start = true;
      security.allow_signup = false;

      app.leaderboard_enabled = false;
      mail.enabled = false;

      server = {
        port = 8080;
        base_path = "/";
        listen_ipv4 = "0.0.0.0";
        listen_ipv6 = "";
      };

      db = {
        port = 5432;
        host = "127.0.0.1";
        user = "wakapi";
        name = "wakapi";
        dialect = "postgres";
      };
    };
  };
}
