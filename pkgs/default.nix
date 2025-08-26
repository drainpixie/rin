{pkgs, ...}:
with pkgs; {
  kc = callPackage ./kc.nix {};
}
