{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.neovim.enable {
    programs.nixvim = {
      plugins = {
        telescope.enable = true;
        web-devicons.enable = true;
      };

      keymaps = [
        {
          action = ":Telescope find_files<CR>";
          key = "<leader>ff";
          mode = "n";
          options.desc = "Find file in project.";
        }
        {
          action = ":Telescope live_grep<CR>";
          key = "<leader>fs";
          mode = "n";
          options.desc = "Find text in project.";
        }
        {
          action = ":Telescope git_files<CR>";
          key = "<leader>fg";
          mode = "n";
          options.desc = "Find file in git.";
        }
      ];
    };
  };
}
