{
  nixpkgs,
  self,
}: f:
nixpkgs.lib.genAttrs [
  "aarch64-linux"
  "i686-linux"
  "x86_64-linux"
  "aarch64-darwin"
  "x86_64-darwin"
] (
  system:
    f {
      inherit system;
      pkgs = nixpkgs.legacyPackages.${system};
      check = self.checks.${system}.pre-commit-check;
    }
)
