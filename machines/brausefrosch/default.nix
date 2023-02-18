{ mkMachine, flakes, ... }:

mkMachine {} ({ lib, pkgs, config, ... }: with lib; {

  system.stateVersion = "23.05";

  wat.installer.hcloud = {
    enable = true;
    macAddress = "96:00:01:ed:b0:4f";
    ipv4Address = "78.46.187.139/32";
    ipv6Address = "2a01:4f8:c012:de06::1/64";
  };

  wat.KoMa = {
    base.enable = true;
    # komapedia.enable = true;
    # matrix-bridge = {
    #   enable = true;
    #   domain = "die-koma.org";
    #   serverName = "matrix.die-koma.org";
    #   ACMEhost = "brausefrosch.die-koma.org";
    #   port = 8008;
    # };
  };

})
