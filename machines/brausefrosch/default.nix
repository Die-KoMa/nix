{ mkMachine, ... }:

mkMachine {} ({ pkgs, ... }: {

  imports = [
    #./hardware-configuration.nix
  ];

})
