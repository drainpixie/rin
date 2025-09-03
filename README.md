![rin](https://socialify.git.ci/drainpixie/rin/image?custom_description=nixos+flake+%2B+home-manager+for+my+systems&description=1&font=Raleway&logo=https%3A%2F%2Fraw.githubusercontent.com%2FNixOS%2Fnixos-artwork%2Frefs%2Fheads%2Fmaster%2Flogo%2Fnix-snowflake-colours.svg&name=1&owner=1&pattern=Circuit+Board&theme=Light)

# hosts

- [timeline](./systems/timeline) dell latitude 5490
- [incubator](./systems/incubator) netcup 500 g11s 

## install 

```sh
# sudo nix run github:nix-community/disko -- --mode disko ./systems/hostname/disko.nix
# sudo nixos-rebuild switch --flake .#hostname
```

## layout 

- `lib/` -> custom functions
- `pkgs/` -> custom derivations
- `overlays/` -> custom overlays
- `secrets/` -> secrets managed via `agenix`
- `systems/<hostname>` -> system-specific configuration
- `modules/` -> mixed `NixOS` and `home-manager` modules 


