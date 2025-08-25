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
  } @ inputs: rec {
    # `sudo nixos-rebuild switch --flake .#hostname`
    lib = nixpkgs.lib // home.lib // (import ./lib {inherit nixpkgs inputs;});

    nixosConfigurations.timeline = lib.mkHost {
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

    checks = lib.forAllSystems (
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
