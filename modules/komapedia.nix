{ mkTrivialModule, config, lib, ... }:
with lib;

mkTrivialModule {
  die-koma.komapedia = { enable = true; };

  sops.secrets = let
    mkSecret = args:
      ({
        mode = "0400";
        owner = "mediawiki";
        group = config.services.nginx.group;
        sopsFile = ../secrets/komapedia.yml;
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
      extraDomainNames = [
        "komapedia.org"
        "de.komapedia.org"
        "www.komapedia.org"
        "42.komapedia.org"
      ];
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
    };

    mysql = {
      ensureDatabases = [ config.services.mediawiki.database.name ];
      ensureUsers = [{ name = config.services.mediawiki.database.user; }];
    };

    nginx = {
      virtualHosts.komapedia = {
        serverName = "de.komapedia.org";
        serverAliases =
          [ "komapedia.org" "www.komapedia.org" "42.komapedia.org" ];
        root = "${config.services.mediawiki.package}/share/mediawiki/";
        locations = {
          "/".extraConfig = ''
            rewrite ^ /wiki/index.php;
          '';
          "/wiki/".alias =
            "${config.services.mediawiki.package}/share/mediawiki/";
          "~ \\.php$".extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.mediawiki.socket};
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            include ${config.services.nginx.package}/conf/fastcgi_params;
          '';
          "~ \\.(js|css|ttf|woff2?|png|jpe?g|svg)$".extraConfig = ''
            add_header Cache-Control "public, max-age=15778463";
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag none;
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header Referrer-Policy no-referrer;
            access_log off;
          '';
        } // (optionalAttrs (config.services.mediawiki.uploadsDir != null) {
          "/images/".alias = "${config.services.mediawiki.uploadsDir}";
        });
      };
    };

    parsoid = {
      enable = true;
      wikis = [ "https://de.komapedia.org/wiki/api.php" ];
    };

  };
  systemd.services.nginx.after = "mysql.service";

}
