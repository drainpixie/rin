{pkgs, ...}: let
  cli = builtins.attrValues {
    inherit
      (pkgs)
      man-pages
      man-pages-posix
      wget
      curl
      jq
      ;
  };
in {
  home.packages = cli;

  systemd.user.startServices = "sd-switch";
  systemd.user.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };
}
