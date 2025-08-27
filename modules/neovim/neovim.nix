{
  wrapNeovimUnstable,
  neovim-unwrapped,
  fennel,
}: let
  config = pkgs.stdenv.mkDerivation {
    name = "nvim-config";
    phases = ["installPhase"];
    nativeBuildInputs = [fennel];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/nvim
      fennel --compile $src/init.fnl > $out/share/nvim/init.lua

      if [ -d $src/fnl ]; then
        mkdir -p $out/share/nvim/lua
        for f in $src/fnl/*.fnl; do
          base="$(basename "$f" .fnl)"
          fennel --compile "$f" > "$out/share/nvim/lua/$base.lua"
        done
      fi

      runHook postInstall
    '';
  };
in
  wrapNeovimUnstable {
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [lazy-nvim];

    wrapRc = "${fennelConfig}/share/nvim/init.lua";
    wrapperArgs = with lib; ''--prefix PATH : "${makeBinPath (lists.unique (lists.flatten binaries))}"'';
  }
