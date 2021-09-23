{

  inputs = {

    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;

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
    ];
    outputs = (wat.lib.eachDefaultSystem (system: pkgs: {
      systemOverlays = [ flakes.sops-nix.overlay ];

      devShell = import ./secrets/shell.nix { inherit pkgs; };

    })) // {

      nixosModules = findModules [ "KoMa" ] ./modules;

      nixosConfigurations = findMachines ./machines;

    };
  });


}
