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

    system.stateVersion = "25.05";

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
          "*.die-koma.org"
        ];
      };
      base.enable = true;
      grafana-cloud.enable = true;
      aksync = {
        enable = true;
        onCalendar = [
          "2025-06-15..23 *:0/5:00"
          "2025-06-24..31 *:0/15:00"
        ];
      };
      kommemeorate = {
        enable = true;

        telegramGroups = {
          "KoMa-memes" = 1884709503;
          "KIF-KoMa-2025-memes" = 2651492607;
        };

        storagePath = "/data/memes";
        databaseUrl = "postgres://kommemeorate@/kommemeorate";
      };
      homepage.enable = true;
      komapedia.enable = true;
      nextcloud.enable = true;
      matrix-bridge = {
        enable = true;
        domain = "die-koma.org";
        serverName = "matrix.die-koma.org";
        port = 8008;
      };
      nginx.enable = true;
      stalwart-mail = {
        enable = true;
        reportDomain = "die-koma.org";
      };
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
