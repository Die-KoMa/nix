{ mkTrivialModule, config, lib, ... }:
with lib;

let
  domainName = "42.komapedia.org";
  extraDomainNames = [
    # "komapedia.org"
    # "de.komapedia.org"
    # "www.komapedia.org"
  ];
  stateDir = "/data/mediawiki";
in mkTrivialModule {
  die-koma.komapedia = {
    enable = true;
    inherit stateDir;
  };

  sops.secrets = let
    mkSecret = args:
      ({
        mode = "0400";
        owner = "mediawiki";
        group = config.services.nginx.group;
        sopsFile = ../secrets/komapedia.yml;
        restartUnits = [ "phpfpm-mediawiki.service" ];
      } // args);
  in {
    komapedia-secret-key = mkSecret {
      key = "secret-key";
      path = "/var/lib/mediawiki/secret.key";
    };
    komapedia-database-password = mkSecret { key = "db-password"; };
    komapedia-upgrade-key = mkSecret { key = "upgrade-key"; };
    komapedia-smw-upgrade-key = mkSecret { key = "smw-upgrade-key"; };
  };

  wat.KoMa = {
    acme = {
      enable = true;
      extraDomainNames = (singleton domainName) ++ extraDomainNames;
    };

    mariadb.enable = true;
    nginx.enable = true;
  };

  services = {
    mediawiki = {
      database = {
        type = "mysql";
        name = "komapedia";
        user = "komapedia";
        tablePrefix = "";
        passwordFile = config.sops.secrets.komapedia-database-password.path;
      };
      passwordFile = config.sops.secrets.komapedia-database-password.path;
    };

    mysql = {
      ensureDatabases = [ config.services.mediawiki.database.name ];
      ensureUsers = [{ name = config.services.mediawiki.database.user; }];
    };

    nginx = {
      virtualHosts.komapedia = {
        onlySSL = true;
        useACMEHost = config.networking.fqdn;
        serverName = domainName;
        serverAliases = extraDomainNames;
        root = "${config.services.mediawiki.finalPackage}/share/mediawiki/";
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ @rewrite";
            index = "index.php";
          };
          "@rewrite".extraConfig = ''
            rewrite ^/(wiki/)?(.*)$ /index.php?title=$1&$args;
            rewrite ^$ /index.php;
          '';
          "~ /wiki/rest.php".tryFiles = "$uri $uri/ /rest.php?$args";
          "^~ /maintenance/".return = "403";
          "~ \\.php$" = {
            fastcgiParams.SCRIPT_FILENAME = "$request_filename";
            extraConfig = ''
              fastcgi_pass unix:${config.services.phpfpm.pools.mediawiki.socket};
            '';
          };
          "~ \\.(js|css|ttf|woff2?|png|jpe?g|svg|ico)$" = {
            tryFiles = "$uri /index.php";
            extraConfig = ''
              expires max;
              log_not_found off;
              access_log off;
            '';
          };
          "/_.gif".extraConfig = ''
            expires max;
            empty_gif;
          '';
          "^~ /cache/".extraConfig = ''
            deny all;
          '';
          "/resources/".alias = "${stateDir}/resources/";
        } // (optionalAttrs (config.services.mediawiki.uploadsDir != null) {
          "/images/".alias = "${config.services.mediawiki.uploadsDir}";
        });
      };
    };
  };
  systemd.services.nginx.after = [ "mysql.service" ];

}
