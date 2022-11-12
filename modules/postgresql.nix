{ mkTrivialModule, config, pkgs, ... }:

mkTrivialModule {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
    };

    postgresqlBackup.enable = true;
  };
}
