{
  lib,
  python311,
  texlive,
  fetchFromGitLab,
  stdenv,
  ...
}:

let
  python3 = python311;
  texlive-dist = texlive.combine {
    inherit (texlive.pkgs)
      collection-basic
      collection-luatex
      collection-latex
      collection-latexrecommended
      collection-latexextra
      collection-fontsrecommended
      collection-fontsextra
      collection-langgerman
      beamer
      ;
  };
in
stdenv.mkDerivation {
  pname = "akplanning";
  version = "unstable-2025-06-25";
  description = "a tool used for modeling, submitting, scheduling and displaying AKs (German: Arbeitskreise), meaning workshops, talks or similar slot-based events";

  src = fetchFromGitLab {
    domain = "gitlab.fachschaften.org";
    owner = "kif";
    repo = "akplanning";
    rev = "2288c5f954d190e91f9f41a834f69d529d9aa443";
    hash = "sha256-/mw9pkGR1L61WCGRmkDnj7MD1GLqYsgWe96LoB1SL8w=";
  };

  propagatedBuildInputs = [
    python3
    texlive-dist
  ];

  installPhase = ''
    cp -R $src $out
  '';

  meta = {
    license = lib.licenses.agpl3Only;
  };
}
