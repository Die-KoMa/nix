{ mkTrivialModule
, pkgs
, config
, ... }:

mkTrivialModule {

  users.groups.homepage = {};
  users.users.homepage = {
    isSystemUser = true;
    group = "homepage";
  };

  systemd.tmpfiles.rules = [
    "d /var/www/homepage 0755 homepage root - -"
  ];

  systemd.services.homepage-rollout = {
    startAt = "*:00/5";
    path = [
      pkgs.nixFlakes
    ];
    script = ''
      nix --print-build-logs --refresh build --out-link /var/www/homepage/htdocs github:die-koma/die-koma.org/release
    '';
    environment.XDG_CACHE_HOME = "/var/cache/homepage-rollout";
    serviceConfig = {
      User = "homepage";
      DynamicUser = true;
      ProtectHome = "tmpfs";
      CacheDirectory = "homepage-rollout";
      ReadWritePaths = [
        "/var/www/homepage"
      ];
    };
  };

  services.nginx.virtualHosts.homepage = {
    serverName = "die-koma.org";
    serverAliases = [
      "www.die-koma.org"
      "new.die-koma.org"
    ];
    forceSSL = true;
    useACMEHost = config.wat.KoMa.nginx.useACMEHost;
    root = "/var/www/homepage/htdocs";
  };

}
