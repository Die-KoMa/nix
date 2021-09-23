{

  inputs = {

    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;

    wat = {
      url = github:thelegy/wat;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  outputs = flakes@{ wat, ... }: wat.lib.mkWatRepo flakes ({ findModules, findMachines, ... }: rec {
    outputs = {

      nixosModules = findModules ["KoMa"] ./modules;

      nixosConfigurations = findMachines ./machines;

    };
  });


}
