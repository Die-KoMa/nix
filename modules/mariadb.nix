{ mkTrivialModule, config, pkgs, lib, ... }:

with lib;

mkTrivialModule {
  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb_1010;
    };

    mysqlBackup.enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/mysql 0700 ${config.services.mysql.user} ${config.services.mysql.group} - -"
    "H /var/lib/mysql - - - - +C"
  ];
}
