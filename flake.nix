{
  description = "faye's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    disko,
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

    mkHost = {
      extraOpts ? {},
      extraModules ? [],
      ...
    }:
      lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};

        modules =
          [
            ./modules/config.nix

            ./systems/${extraOpts.host}/host.nix
            ./systems/${extraOpts.host}/part.nix

            {
              my = extraOpts;

              nixpkgs.overlays = [
                (self: super: {
                  faye = faye.packages.${super.system};
                })
              ];

              system.stateVersion = "25.11";
            }

            home.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.akemi = {
                  home.stateVersion = "25.11";
                  imports = [
                    ./systems/timeline/home.nix
                    vim.homeModules.nixvim
                  ];
                };
              };
            }

            (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "akemi"])
          ]
          ++ extraModules;
      };
  in {
    # `sudo nixos-rebuild switch --flake .#hostname`

    nixosConfigurations.timeline = mkHost {
      extraModules = [
        hardware.nixosModules.dell-latitude-5520
        disko.nixosModules.disko
      ];

      extraOpts = {
        architecture = "x86_64-linux";

        host = "timeline";
        user = "akemi";

        git.user = "drainpixie";
        git.email = "121581793+drainpixie@users.noreply.github.com";
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
