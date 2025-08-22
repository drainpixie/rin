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

        starship = {
          enable = true;
          enableZshIntegration = true;
          settings =
            {
              format = "$username$directory$git_branch$character";
              add_newline = false;

              directory = {
                format = "[$path]($style) ";
                style = "blue";
                fish_style_pwd_dir_length = 1;
                truncation_length = 1;
                truncate_to_repo = true;
              };

              git_branch = {
                format = "[$branch]($style) ";
                style = "purple";
              };

              character = {
                success_symbol = "[\\$](green)";
                error_symbol = "[\\$](red)";
              };
            }
            // lib.genAttrs ["username" "aws" "gcloud" "nodejs" "python" "rust" "golang" "php" "java" "docker_context" "package" "cmake" "conda" "dart" "deno" "dotnet" "elixir" "elm" "erlang" "helm" "julia" "kotlin" "kubernetes" "lua" "nim" "nix_shell" "ocaml" "perl" "purescript" "red" "ruby" "scala" "swift" "terraform" "vlang" "zig" "cmd_duration" "line_break" "jobs" "battery" "time" "status" "memory_usage" "env_var" "custom" "sudo" "localip"] (_: {disabled = true;});
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

          initContent = ''
            bindkey "^[[1;5C" forward-word    # Ctrl+Right
            bindkey "^[[1;5D" backward-word   # Ctrl+Left

            bindkey "^[OC" forward-word       # Alt+Right (fallback)
            bindkey "^[OD" backward-word      # Alt+Left (fallback)
            bindkey "^[[5C" forward-word      # Ctrl+Right (alternative)
            bindkey "^[[5D" backward-word     # Ctrl+Left (alternative)
          '';

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
