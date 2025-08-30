{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.neovim.enable {
    programs.nixvim = {
      plugins.oil = {
        enable = true;
        settings = {
          columns = [
            "icon"
          ];

          preview = {
            border = "rounded";

            size = {
              width = 0.5;
              height = 0.5;
            };

            win_options = {
              winhighlight = "Normal:Normal,FloatBorder:Normal";
            };
          };

          view_options.show_hidden = true;
        };
      };

      keymaps = [
        {
          action = ":Oil<CR>";
          key = "-";
          mode = "n";
          options.desc = "Open parent directory";
        }
      ];
    };
  };
}
