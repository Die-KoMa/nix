{ mkTrivialModule, config, pkgs, ... }:

mkTrivialModule {
  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb_1010;
    };

    mysqlBackup.enable = true;
  };
}
