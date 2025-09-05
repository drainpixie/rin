{pkgs, ...}: {
  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      root = pkgs.runCommand "www" {} ''
        mkdir -p $out
        cat > $out/index.html <<'HTML'
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <title>Incubator</title>
          </head>
          <body>
            <h1>Hello from Nginx inside the NixOS VM</h1>
            <p>This is a simple HTML page served by Nginx.</p>
          </body>
        </html>
        HTML
      '';
    };
  };
}
