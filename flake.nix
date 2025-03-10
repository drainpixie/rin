{
  description = "faye's nixos configuration";

  inputs = {
    hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    faye = {
      url = "sourcehut:~pixie/hyo";
      inputs.hooks.follows = "hooks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    home-manager,
    hardware,
    nixpkgs,
    hooks,
    self,
    faye,
    vim,
    ...
  } @ inputs: let
    lib = nixpkgs.lib // home-manager.lib;

    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = lib.genAttrs systems;

    mkSystem = host: system: extraModules:
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };

        modules = extraModules ++ [./hosts/${host}];
      };

    mkHome = user: system: extraModules:
      lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };

        extraSpecialArgs = {
          inherit inputs;
        };

        modules =
          extraModules
          ++ [
            ./users/${user}
            {
              nixpkgs.overlays = [
                (self: super: {
                  faye = faye.packages.${super.system};
                })
              ];
            }
          ];
      };
  in {
    # `nixos-rebuild switch --flake .#hostname`
    nixosConfigurations = {
      timeline =
        mkSystem "timeline" "x86_64-linux"
        [hardware.nixosModules.dell-latitude-5520];

      incubator =
        mkSystem "incubator" "x86_64-linux"
        [
          hardware.nixosModules.common-cpu-intel-sandy-bridge
          hardware.nixosModules.common-pc-hdd
        ];
    };

    # `home-manager switch --flake .#username@hostname`
    homeConfigurations = {
      "akemi@timeline" = mkHome "akemi" "x86_64-linux" [vim.homeManagerModules.nixvim];
      "kyubey@incubator" = mkHome "kyubey" "x86_64-linux";
    };

    checks = forAllSystems (system: let
      lib = hooks.lib.${system};
    in {
      pre-commit-check = lib.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix = {
            enable = true;
            settings.ignore = ["/.direnv"];
          };
        };
      };
    });

    devShells = forAllSystems (system: let
      check = self.checks.${system}.pre-commit-check;
    in {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (check) shellHook;
        buildInputs = check.enabledPackages;
      };
    });
  };
}
