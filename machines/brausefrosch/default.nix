{ mkMachine, flakes, ... }:

mkMachine { } ({ lib, pkgs, config, ... }:
  with lib; {

    system.stateVersion = "23.05";

    wat.installer.hcloud = {
      enable = true;
      macAddress = "96:00:01:ed:b0:4f";
      ipv4Address = "78.46.187.139/32";
      ipv6Address = "2a01:4f8:c012:de06::1/64";
    };

    wat.KoMa = {
      base.enable = true;
      nginx.enable = true;
      homepage.enable = true;
      # komapedia.enable = true;
      # matrix-bridge = {
      #   enable = true;
      #   domain = "die-koma.org";
      #   serverName = "matrix.die-koma.org";
      #   ACMEhost = "brausefrosch.die-koma.org";
      #   port = 8008;
      # };

      acme = {
        enable = true;
        staging = true;
        extraDomainNames =
          [ "die-koma.org" "new.die-koma.org" "www.die-koma.org" ];
      };
    };

    wat.thelegy.backup.enable = true;

    services.nginx.virtualHosts.homepage = let
      clientConfig = {
        "m.homeserver".base_url = "https://matrix.die-koma.org";
        "m.identity_server" = { };
      };
      serverConfig."m.server" = "matrix.die-koma.org:443";

      mkWellKnown = data: ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, OPTIONS';
        add_header Access-Control-Allow-Headers 'X-Requested-With, Content-Type, Authorization';
        return 200 '${builtins.toJSON data}';
      '';
    in {
      locations."/.well-known/matrix/server".extraConfig =
        mkWellKnown serverConfig;
      locations."/.well-known/matrix/client".extraConfig =
        mkWellKnown clientConfig;
    };

  })
