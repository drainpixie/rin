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
    lib = nixpkgs.lib // home.lib // (import ./lib {inherit nixpkgs inputs self;});

    # nixos-rebuild switch --flake ".?submodules=1#timeline"
    nixosConfigurations = let
      extraSpecialArgs.tools = lib;
      mkExtraOpts = attrs:
        {
          architecture = "x86_64-linux";
          git = {
            name = "drainpixie";
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

    checks = lib.forAllSystems ({system, ...}: {
      pre-commit-check = hooks.lib.${system}.run {
        src = ./.;
        hooks =
          {
            statix = {
              enable = true;
              settings.ignore = ["/.direnv"];
            };
          }
          // lib.enableMany ["stylua" "convco" "alejandra"];
      };
    });

    devShells = lib.forAllSystems ({
      pkgs,
      check,
      ...
    }: {
      default = pkgs.mkShell {
        inherit (check) shellHook;
        buildInputs = check.enabledPackages;
      };
    });

    formatter = lib.forAllSystems ({pkgs, ...}: pkgs.alejandra);
  };
}
