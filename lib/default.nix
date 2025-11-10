{
  nixpkgs,
  inputs,
  self,
  ...
}: {
  enableMany = import ./enableMany.nix;
  mkHost = import ./mkHost.nix {inherit nixpkgs inputs;};
  forAllSystems = import ./forAllSystems.nix {inherit nixpkgs self;};
}
