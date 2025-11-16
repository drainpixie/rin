{
  nixpkgs,
  inputs,
  self,
  ...
}: {
  setMany = import ./setMany.nix {inherit nixpkgs;};
  mkHost = import ./mkHost.nix {inherit nixpkgs inputs;};
  mkServiceOption = import ./mkServiceOption.nix {inherit nixpkgs;};
  forAllSystems = import ./forAllSystems.nix {inherit nixpkgs self;};
}
