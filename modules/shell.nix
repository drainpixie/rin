{
  config,
  pkgs,
  lib,
  ...
}: {
  options.my.shell.minimal = lib.mkEnableOption "faye's minimal zsh configuration, now with fewer tools";
  options.my.shell.enable = lib.mkEnableOption "faye's zsh configuration with modern CLI tools";

  config = lib.mkIf config.my.shell.enable {
    programs.zsh.enable = true;
    users.users."${config.my.user}".shell = pkgs.zsh;

    hm = {
      programs = {
        direnv = {
          enable = true;
          enableZshIntegration = true;
        };

        zoxide = lib.mkIf (!config.my.shell.minimal) {
          enable = true;
          enableZshIntegration = true;
        };

        fzf = {
          enable = true;
          enableZshIntegration = true;
        };

        eza = {
          enable = true;
          enableZshIntegration = true;

          extraOptions = [
            "--group-directories-first"
            "--sort=ext"
          ];
        };

        ripgrep = {
          enable = true;

          arguments = [
            "--hidden"
            "--smart-case"
          ];
        };

        bat = lib.mkIf (!config.my.shell.minimal) {
          enable = true;
          config = {
            theme = "ansi";
            style = "plain";
          };
        };

        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = !config.my.shell.minimal;
          syntaxHighlighting.enable = !config.my.shell.minimal;
          historySubstringSearch.enable = !config.my.shell.minimal;

          history = {
            share = true;
            extended = true;
            ignoreDups = true;
            ignoreSpace = true;
            expireDuplicatesFirst = true;
          };

          setOptions = [
            "HIST_APPEND"
            "HIST_REDUCE_BLANKS"
            "HIST_SAVE_NO_DUPS"
            "HIST_VERIFY"
            "EXTENDED_GLOB"
            "GLOB_DOTS"
            "AUTO_CD"
            "CORRECT"
            "NO_CASE_GLOB"
            "SHARE_HISTORY"
            "APPEND_HISTORY"
            "INC_APPEND_HISTORY"
            "HIST_IGNORE_ALL_DUPS"
            "MENU_COMPLETE"
            "AUTO_LIST"
            "COMPLETE_IN_WORD"
            "ALWAYS_TO_END"
          ];

          shellAliases = {
            c = "clear";
            cd = lib.mkIf (!config.my.shell.minimal) "z";
            mkdir = "mkdir -pv";

            df = "df -h";
            du = "du -h";
            free = "free -h";
            wget = "wget -c";
            ping = "ping -c 5";

            rm = "rm -i";
            mv = "mv -i";

            cat = lib.mkIf (!config.my.shell.minimal) "bat";
            grep = "rg --color=always --hidden --smart-case";
          };
        };
      };
    };
  };
}
