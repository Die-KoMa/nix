{ mkTrivialModule, config, pkgs, lib, ... }:

with lib;

mkTrivialModule {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
    };

    postgresqlBackup = {
      enable = true;
      backupAll = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/postgresql 0750 postgres postgres - -"
    "H /var/lib/postgresql - - - - +C"
  ];

}
