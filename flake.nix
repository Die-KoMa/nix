{

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    komapedia = {
      url = "github:Die-KoMa/mediawiki";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wat = {
      url = "github:thelegy/wat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = flakes@{ wat, nixpkgs, sops-nix, ... }:
    let inherit (nixpkgs.lib) attrValues;
    in wat.lib.mkWatRepo flakes ({ findModules, findMachines, ... }: {
      loadModules = [ flakes.sops-nix.nixosModules.sops ]
        ++ (attrValues flakes.komapedia.nixosModules);
      loadOverlays = (attrValues flakes.komapedia.overlays);
      outputs = {
        devShells = wat.lib.withPkgsFor [ "x86_64-linux" ] nixpkgs
          [ flakes.sops-nix.overlay ]
          (pkgs: { default = import ./secrets/shell.nix { inherit pkgs; }; });

        nixosModules = findModules [ "KoMa" ] ./modules;

        nixosConfigurations = findMachines ./machines;

      };
    });

}
