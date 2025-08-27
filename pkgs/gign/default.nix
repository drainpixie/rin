{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "gign";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "metafates";
    repo = pname;
    rev = "HEAD";
    hash = "sha256-YsGq1Dsy1gj9EMBxG42DkgYlfjuRyR8ohCkohQiq5QU=";
  };

  meta = {
    description = "A cute .gitignore generator";
    homepage = "https://github.com/metafates/${pname}";
    license = lib.licenses.mit;
  };

  cargoPatches = [./lockfile.patch]; # note: not in og repo
  cargoHash = "sha256-E2h6dGOexntFWuLo8xWkj9Y3lXdIEUOa7K3sAw5q/Wg=";
}
