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

    age = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    website = {
      url = "github:drainpixie/www";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hooks.follows = "hooks";
    };
  };

  outputs = {
    hardware,
    nixpkgs,
    website,
    disko,
    hooks,
    home,
    self,
    vim,
    age,
    ...
  } @ inputs: rec {
    lib = nixpkgs.lib // home.lib // (import ./lib {inherit nixpkgs inputs;});

    # nixos-rebuild switch --flake ".?submodules=1#timeline"
    nixosConfigurations = let
      extraSpecialArgs.tools = lib;
      mkExtraOpts = attrs:
        {
          architecture = "x86_64-linux";
          git = {
            user = "drainpixie";
            email = "121581793+drainpixie@users.noreply.github.com";
          };
        }
        // attrs;
    in {
      timeline = lib.mkHost {
        inherit extraSpecialArgs;

        extraModules = [
          vim.nixosModules.nixvim
          age.nixosModules.default
          disko.nixosModules.disko
          hardware.nixosModules.dell-latitude-5520
        ];

        extraOpts = mkExtraOpts {
          host = "timeline";
          user = "akemi";
        };
      };

      incubator = lib.mkHost {
        inherit extraSpecialArgs;

        extraModules = [
          vim.nixosModules.nixvim
          age.nixosModules.default
          disko.nixosModules.disko
          hardware.nixosModules.common-pc
          hardware.nixosModules.common-pc-ssd
        ];

        extraOpts = mkExtraOpts {
          host = "incubator";
          user = "kyubey";
        };
      };
    };

    checks = lib.forAllSystems (
      system: let
        hooksLib = hooks.lib.${system};
      in {
        pre-commit-check = hooksLib.run {
          src = ./.;
          hooks =
            lib.enableMany ["stylua" "convco" "alejandra"]
            // {
              statix = {
                enable = true;
                settings.ignore = ["/.direnv"];
              };
            };
        };
      }
    );

    devShells = lib.forAllSystems (
      system: let
        check = self.checks.${system}.pre-commit-check;
      in {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (check) shellHook;
          buildInputs = check.enabledPackages;
        };
      }
    );

    formatter = lib.forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.alejandra
    );
  };
}
