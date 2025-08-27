{
  wrapNeovimUnstable,
  neovim-unwrapped,
  neovimUtils,
  vimPlugins,
  fennel,
  stdenv,
  ...
}: let
  compiled = stdenv.mkDerivation {
    name = "fennel-compiled";

    unpackPhase = "false";
    phases = ["buildPhase" "installPhase"];

    nativeBuildInputs = [fennel];

    src = ./config;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lua
      fennel --compile $src/init.fnl > $out/init.lua

      if [ -d $src/fnl ]; then
        find $src/fnl -name '*.fnl' | while read -r f; do
          rel="''${f#$src/fnl/}"
          outpath="$out/lua/''${rel%.fnl}.lua"
          mkdir -p "$(dirname "$outpath")"
          fennel --compile "$f" > "$outpath"
        done
      fi

      runHook postInstall
    '';
  };

  config = neovimUtils.makeNeovimConfig {
    viAlias = true;
    vimAlias = true;

    plugins = with vimPlugins; [lazy-nvim];

    customLuaRC = ''
      vim.opt.runtimepath:append(vim.fn.expand("${compiled}"))
      dofile(vim.fn.expand('${compiled}/init.lua'))
    '';
  };
in
  wrapNeovimUnstable neovim-unwrapped config
