{pkgs, ...}:
with pkgs; {
  drafting-mono = callPackage ./drafting-mono.nix {};
  azuki = callPackage ./azuki.nix {};

  kc = callPackage ./kc.nix {};
  gign = callPackage ./gign {};

  ori = callPackage ./ori {};
  alabaster = callPackage ./alabaster {};
}
