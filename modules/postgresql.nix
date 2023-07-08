{ mkTrivialModule, config, pkgs, lib, ... }:

with lib;

mkTrivialModule {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
    };

    postgresqlBackup.enable = true;
  };

  systemd.tmpfiles.rules = let
    mode = if config.services.postgresql.groupAccessAvailable then
      "0750"
    else
      "0700";
  in [
    "d /var/lib/postgresql ${mode} postgres postgres - -"
    "H /var/lib/postgresql - - - - +C"
  ];

}
