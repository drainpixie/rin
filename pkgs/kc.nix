{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "kc";
  version = "v1.1.0";

  src = fetchFromGitHub {
    repo = pname;
    rev = version;
    owner = "aslilac";
    hash = "sha256-8/88bTrSdjhdOMzXNEbcpiIKfO+Ks3LL3AtfUHat0Kc=";
  };

  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 build/*/release/kc $out/bin/kc
    runHook postInstall
  '';

  meta = {
    description = "Kayla's (line) counter (of code) :)";
    homepage = "https://github.com/aslilac/kc";
    license = lib.licenses.mpl20;
  };

  cargoHash = "sha256-dk1wzHBna+2/ORKZ4KJez0j7OlLyQgItnMwvnIrNIOw=";
}
