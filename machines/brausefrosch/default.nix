{ mkMachine, flakes, ... }:

mkMachine { } (
  {
    lib,
    pkgs,
    config,
    ...
  }:
  with lib;
  {

    system.stateVersion = "24.11";

    wat.installer.hcloud = {
      enable = true;
      macAddress = "96:00:01:ed:b0:4f";
      ipv4Address = "78.46.187.139/32";
      ipv6Address = "2a01:4f8:c012:de06::1/64";
    };

    wat.KoMa = {
      acme = {
        enable = true;
        staging = false;
        extraDomainNames = [
          "die-koma.org"
          "new.die-koma.org"
          "www.die-koma.org"
        ];
      };
      base.enable = true;
      grafana-cloud.enable = true;
      homepage.enable = true;
      komapedia.enable = true;
      nextcloud.enable = true;
      matrix-bridge = {
        enable = true;
        domain = "die-koma.org";
        serverName = "matrix.die-koma.org";
        ACMEhost = "brausefrosch.die-koma.org";
        port = 8008;
      };
      nginx.enable = true;
      stalwart-mail.enable = true;
    };

    wat.thelegy.backup = {
      enable = true;
      borgbaseRepo = "xprokp58";
      extraReadWritePaths = [
        "/.backup-snapshots"
        "/data/.backup-snapshots"
      ];
    };

    fileSystems."/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "discard=async"
        "noatime"
      ];
    };
  }
)
