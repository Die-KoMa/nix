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


  outputs = flakes@{ wat, ... }: wat.lib.mkWatRepo flakes ({ findModules, findMachines, ... }: rec {
    loadModules = [
      flakes.sops-nix.nixosModules.sops
    ];
    outputs = {

      nixosModules = findModules [ "KoMa" ] ./modules;

      nixosConfigurations = findMachines ./machines;

      devShell.x86_64-linux = import ./secrets/shell.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        sops-nix = inputs.sops-nix.packages.x86_64-linux;
      };

    };
  });


}
