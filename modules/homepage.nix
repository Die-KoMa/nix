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

  services.nginx.virtualHosts.homepage-preview = {
    serverName = "new.die-koma.org";
    serverAliases = [
    ];
    forceSSL = true;
    useACMEHost = config.wat.KoMa.nginx.useACMEHost;
    root = "/var/www/homepage/preview";
    extraConfig = ''
      ssi on;
      ssi_types *;
      subrequest_output_buffer_size 64k;
    '';
    locations."~ /https://([^/\\n]+)/(.*)" = {
      proxyPass = "https://$1/$2?$args";
      extraConfig = ''
        internal;
        ssi off;
        resolver 127.0.0.53;
        proxy_ssl_name $1;
        proxy_ssl_server_name on;
        proxy_pass_request_headers off;
        proxy_pass_request_body off;
      '';
    };
  };

  services.nginx.virtualHosts.homepage = {
    serverName = "die-koma.org";
    serverAliases = [
    ];
    forceSSL = true;
    useACMEHost = config.wat.KoMa.nginx.useACMEHost;
    root = "/var/www/homepage/htdocs";
    extraConfig = ''
      ssi on;
      ssi_types *;
      subrequest_output_buffer_size 64k;
    '';
    locations."~ /https://([^/\\n]+)/(.*)" = {
      proxyPass = "https://$1/$2?$args";
      extraConfig = ''
        internal;
        ssi off;
        resolver 127.0.0.53;
        proxy_ssl_name $1;
        proxy_ssl_server_name on;
        proxy_pass_request_headers off;
        proxy_pass_request_body off;
      '';
    };
  };

  services.nginx.virtualHosts.homepage-redirect = {
    serverName = "www.die-koma.org";
    serverAliases = [
    ];
    forceSSL = true;
    useACMEHost = config.wat.KoMa.nginx.useACMEHost;
    globalRedirect = "die-koma.org";
  };

}
