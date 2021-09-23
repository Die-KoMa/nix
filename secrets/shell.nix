{ pkgs ? import <nixpkgs> { }
, sops-nix ? pkgs.callPackage <sops-nix> { }
, ...
}:

pkgs.mkShell {
  sopsPGPKeyDirs = [ ./keys/users ./keys/hosts ];

  nativeBuildInputs = [ sops-nix.sops-import-keys-hook ];
}
