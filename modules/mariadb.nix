{ mkTrivialModule, config, pkgs, ... }:

mkTrivialModule {
  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb_108;
    };

    mysqlBackup.enable = true;
  };
}
