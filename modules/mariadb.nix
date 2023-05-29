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

  fileSystems = mkIf config.wat.installer.btrfs.enable {
    "/var/lib/mysql".options = [ "nocow" ];
  };
}
