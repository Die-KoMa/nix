{ mkTrivialModule, config, pkgs, lib, ... }:

with lib;

let
  domainName = "cloud.die-koma.org";
  extraDomainNames = [ ];
  home = "/data/nextcloud";
  shortlinks = {
    public = "/s/Li2bQd4q5p8NMCR";
    koma61 = "/s/k4dcMGq5dEqJqLB";
    koma64 = "/s/rMQfoRsQSwmEwCX";
    koma65 = "/s/jFTksRPfY94pF78";
    koma66 = "/s/H5kxttxd26YiaSQ";
    koma67 = "/s/5DztHrxry6tfxzo";
    koma68 = "/s/LfFiEGp7xjQsmqE";
    koma69 = "/s/XNGCTBj5gifNS45";
    koma70 = "/s/EatMniZNFfCNZLj";
    koma71 = "/s/73eSmezMFLZxSSB";
    koma72 = "/s/QCYaJ6fW6kfzfDz";
    koma73 = "/s/DSGxY43LwBy3kbP";
    koma74 = "/s/GWYLCEMRgiDiQpD";
    koma75 = "/s/QCwbNkst4CiRMWG";
    koma76 = "/s/TFezieeJzsK3knM";
    koma77 = "/s/ACR2bGy8YgSsCWa";
    koma78 = "/s/oCfeqKJ26tcJeEq";
    koma79 = "/s/tRNcgNGyzNeA9Wf";
    koma80 = "/s/a96eaNFyT77rNgH";
    koma81 = "/s/XYwsLGXTDJzZCw7";
    koma82 = "/s/zWb6fCRxwbYE7Zj";
    koma83 = "/s/sxdwt5BbB2Tjo4L";
    koma84 = "/s/fqZFxSFiJGqMZF6";
    koma85 = "/s/dNjXwPRSiEFeJJY";
    koma86 = "/s/4gFEg854HSJoZtf";
    koma87 = "/s/386rSxrDjp36aL6";
    koma88 = "/s/wP5FJkrG93pZsnY";
  };
in mkTrivialModule {

  wat.KoMa = {
    nginx.enable = true;
    mariadb.enable = true;
    acme.extraDomainNames = [ domainName ] ++ extraDomainNames;
  };

  sops.secrets.nextcloud-admin-pass = {
    mode = "0400";
    owner = "nextcloud";
  };

  sops.secrets.nextcloud-secrets = {
    mode = "0400";
    owner = "nextcloud";
  };

  services.redis = {
    vmOverCommit = true;
    servers.nextcloud.save = [ ];
  };

  services.nextcloud = {
    enable = true;
    hostName = domainName;
    package = pkgs.nextcloud27;
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "mysql";
      adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
      adminuser = "admin";
      extraTrustedDomains = extraDomainNames;
      defaultPhoneRegion = "DE";
    };
    configureRedis = true;
    home = home;
    secretFile = config.sops.secrets.nextcloud-secrets.path;
  };

  services.nginx.virtualHosts.${domainName} = {
    forceSSL = true;
    useACMEHost = config.wat.KoMa.nginx.useACMEHost;
    serverAliases = extraDomainNames;
    locations = mapAttrs' (link: target:
      nameValuePair "/${link}" {
        return = "301 https://${domainName}${target}";
      }) shortlinks;
  };

}
