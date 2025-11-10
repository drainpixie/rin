_: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "faye.keller06+web@gmail.com";
  };

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

    virtualHosts = {
      "drainpixie.xyz" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3001/";
            proxyWebsockets = true;
          };
        };
      };

      "waka.drainpixie.xyz" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8080/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };

  systemd.services.nginx.serviceConfig.ProtectHome = false;
  networking.firewall.allowedTCPPorts = [80 443];
}
