{
  nixpkgs,
  inputs,
}: {
  extraOpts ? {},
  extraModules ? [],
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {inherit inputs;};

  modules =
    [
      ../modules/config.nix

      ../systems/${extraOpts.host}/host.nix
      ../systems/${extraOpts.host}/part.nix

      {
        my = extraOpts;

        nixpkgs.overlays = [
          (self: super: {
            faye = inputs.faye.packages.${super.system};
          })
        ];

        system.stateVersion = "25.11";
      }

      inputs.home.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.akemi = {
            home.stateVersion = "25.11";
            imports = [
              ../systems/timeline/home.nix
              inputs.vim.homeModules.nixvim
            ];
          };
        };
      }

      (nixpkgs.lib.mkAliasOptionModule ["hm"] ["home-manager" "users" extraOpts.user])
    ]
    ++ extraModules;
}
