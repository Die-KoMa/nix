{
  mkTrivialModule,
  config,
  lib,
  ...
}:

mkTrivialModule {
  die-koma.akplanning = {
    enable = true;
    nginx = true;
  };

  sops.secrets =
    let
      mkSecret =
        args:
        (
          {
            mode = "0400";
            owner = "akplanning";
            group = "akplanning";
            sopsFile = ../secrets/akplanning.yml;
            restartUnits = [ "akplanning.service" ];
          }
          // args
        );
    in
    {
      akplanning-secret-key = mkSecret { key = "secret-key"; };
      akplanning-database-password = mkSecret { key = "db-password"; };
    };

  wat.KoMa.acme = {
    enable = true;
    extraDomainNames = lib.concatLists [
      (lib.singleton config.die-koma.akplanning.hostName)
      config.die-koma.akplanning.extraHostNames
    ];
  };
}
