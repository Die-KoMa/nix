{ mkTrivialModule, config, lib, ... }:
with lib;

let
  domainName = "de.komapedia.org";
  extraDomainNames = [ "komapedia.org" "www.komapedia.org" ];
  fileDomainName = "file.komapedia.org";
  extraFileDomainNames = [ "die-reso.org" "reso.die-orga.org" ];
  stateDir = "/data/mediawiki";
in mkTrivialModule {
  die-koma.komapedia = {
    enable = true;
    inherit stateDir;

    poweredBy.hetzner = {
      alt = "hosted by HETZNER";
      logo = "/images/hosted-by-hetzner.png";
      link = "https://www.hetzner.com/cloud";
      height = 36;
      width = 103;
    };
  };

  sops.secrets = let
    mkSecret = args:
      ({
        mode = "0400";
        owner = "mediawiki";
        group = config.services.nginx.group;
        sopsFile = ../../secrets/komapedia.yml;
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
      extraDomainNames = concatLists [
        (singleton domainName)
        extraDomainNames
        (singleton fileDomainName)
        extraFileDomainNames
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
      passwordFile = config.sops.secrets.komapedia-database-password.path;
    };

    mysql = {
      ensureDatabases = [ config.services.mediawiki.database.name ];
      ensureUsers = [{ name = config.services.mediawiki.database.user; }];
    };

    nginx = {
      virtualHosts = {
        komapedia-file = {
          forceSSL = true;
          useACMEHost = config.networking.fqdn;
          serverName = fileDomainName;
          serverAliases = extraFileDomainNames;

          locations = {
            "/".extraConfig = ''
              rewrite ^/(.*)$ https://${domainName}/wiki/Spezial:Weiterleitung/file/$1 redirect;
            '';
          };
        };

        komapedia = {
          forceSSL = true;
          useACMEHost = config.networking.fqdn;
          serverName = domainName;
          serverAliases = extraDomainNames;
          root = "${config.services.mediawiki.finalPackage}/share/mediawiki/";
          locations = {
            "/" = {
              tryFiles = "$uri $uri/ @rewrite";
              index = "index.php";
            };
            "^~ /wiki/".extraConfig = ''
              rewrite ^/wiki/(?<pagename>.*)$ /index.php;
            '';
            "@rewrite".extraConfig = ''
              rewrite ^/(.*)$ /index.php?title=$1&$args;
              rewrite ^$ /index.php;
            '';
            "~ /wiki/rest.php".tryFiles = "$uri $uri/ /rest.php?$query_string";
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
            "^~ /resources/".alias =
              "${config.services.mediawiki.finalPackage}/share/mediawiki/resources/";
          } // (optionalAttrs (config.services.mediawiki.uploadsDir != null) {
            "^~ /images/".alias = "${config.services.mediawiki.uploadsDir}";
            "=/images/hosted-by-hetzner.png".alias =
              ./hosted-by-hetzner-201.png;
            "=/images/komapedia-logo.png".alias = ./komapedia-logo.png;
            "^~ /images/deleted".extraConfig = ''
              deny all;
            '';
          });
        };
      };
    };
  };

  users.users.nginx.extraGroups = [ "mediawiki" ];

  systemd.services.nginx.after = [ "mysql.service" ];

}
