{
  lib,
  pkgs,
  mkDerivation,
  ...
}:

mkDerivation {
  pname = "akplanning";
  version = "unstable-2025-06-25";
  description = "a tool used for modeling, submitting, scheduling and displaying AKs (German: Arbeitskreise), meaning workshops, talks or similar slot-based events";

  src = pkgs.fetchFromGitLab {
    domain = "gitlab.fachschaften.org";
    owner = "kif";
    repo = "akplanning";
    rev = "2288c5f954d190e91f9f41a834f69d529d9aa443";
    hash = "sha256-/mw9pkGR1L61WCGRmkDnj7MD1GLqYsgWe96LoB1SL8w=";
  };

  meta = {
    license = lib.licenses.agpl3Only;
  };
}
