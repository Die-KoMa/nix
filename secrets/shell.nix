{ pkgs ? import <nixpkgs> { }
, sops-import-keys-hook ? pkgs.sops-import-keys-hook
, ...
}:

pkgs.mkShell {
  sopsPGPKeyDirs = [ ./keys/users ./keys/hosts ];

  nativeBuildInputs = [ sops-import-keys-hook ];
}
