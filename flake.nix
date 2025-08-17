{
  description = "faye's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";

    hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    faye = {
      url = "sourcehut:~pixie/hyo";
      inputs.hooks.follows = "hooks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    hardware,
    nixpkgs,
    hooks,
    home,
    self,
    faye,
    vim,
    ...
  } @ inputs: let
    lib = nixpkgs.lib // home.lib;

    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = lib.genAttrs systems;

    mkHost = let
      state = "25.11";
    in
      {
        opts ? {},
        extraModules ? [],
      }:
        lib.nixosSystem {
          system = opts.architecture;

          specialArgs = {inherit inputs opts;};

          modules =
            [
              ./modules/config.nix

              ./systems/${opts.host}/host.nix
              ./systems/${opts.host}/hardware.nix

              {
                nixpkgs.overlays = [
                  (self: super: {
                    faye = faye.packages.${super.system};
                  })
                ];

                system.stateVersion = state;
              }

              home.nixosModules.home-manager
              {
                home-manager = {
                  extraSpecialArgs = {inherit opts;};
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${opts.user} = {
                    home.stateVersion = state;

                    imports = [
                      ./systems/${opts.host}/home.nix
                      vim.homeModules.nixvim
                    ];
                  };
                };
              }
            ]
            ++ extraModules;
        };
  in {
    # `nixos-rebuild switch --flake .#hostname`

    nixosConfigurations.timeline = mkHost {
      extraModules = [hardware.nixosModules.dell-latitude-5520];

      opts = {
        editor = "nvim";
        user = "akemi";
        host = "timeline";
        architecture = "x86_64-linux";
      };
    };

    checks = forAllSystems (
      system: let
        lib = hooks.lib.${system};
      in {
        pre-commit-check = lib.run {
          src = ./.;
          hooks = {
            convco.enable = true;
            alejandra.enable = true;
            statix = {
              enable = true;
              settings.ignore = ["/.direnv"];
            };
          };
        };
      }
    );

    devShells = forAllSystems (
      system: let
        check = self.checks.${system}.pre-commit-check;
      in {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (check) shellHook;
          buildInputs = check.enabledPackages;
        };
      }
    );

    formatter = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.alejandra
    );
  };
}
