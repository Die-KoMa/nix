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

  fileSystems = mkIf config.wat.installer.btrfs.enable {
    "/var/lib/postgresql".options = [ "nocow" ];
  };
}
