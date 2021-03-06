{

  inputs = {

    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;

    komapedia = {
      url = github:Die-KoMa/mediawiki;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wat = {
      url = github:thelegy/wat;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  outputs = flakes@{ wat, nixpkgs, sops-nix, ... }: wat.lib.mkWatRepo flakes ({ findModules, findMachines, ... }: {
    loadModules = [
      flakes.sops-nix.nixosModules.sops
    ] ++ (nixpkgs.lib.attrValues flakes.komapedia.nixosModules);
    loadOverlays = [
      flakes.komapedia.overlay
    ];
    outputs = {
      devShell = wat.lib.withPkgsFor [ "x86_64-linux" ] nixpkgs [ flakes.sops-nix.overlay ]
        (pkgs:
          import ./secrets/shell.nix { inherit pkgs; }
        );

      nixosModules = findModules [ "KoMa" ] ./modules;

      nixosConfigurations = findMachines ./machines;

    };
  });


}
