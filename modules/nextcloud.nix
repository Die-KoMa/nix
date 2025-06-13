{
  mkTrivialModule,
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  domainName = "cloud.die-koma.org";
  extraDomainNames = [ ];
  home = "/data/nextcloud";
  shortlinks = {
    awareness = "/s/PaYHcFKBCDGniRb";
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
    koma89 = "/s/xT2cq4rBpySm9RK";
    koma90 = "/s/RbKLAQXSn25PGTY";
    koma91 = "/s/LFx9XSwaRSLQCrL";
  };
in
mkTrivialModule {

  wat.KoMa = {
    nginx.enable = true;
    mariadb.enable = true;
  };

  sops.secrets.nextcloud-admin-pass = {
    mode = "0400";
    owner = "nextcloud";
  };

  sops.secrets.nextcloud-secrets = {
    mode = "0400";
    owner = "nextcloud";

    # apparently, the cloud dislikes redeployed secrets, so make sure
    # to reload it
    reloadUnits = [ "phpfpm-nextcloud.service" ];
  };

  services.redis = {
    vmOverCommit = true;
    servers.nextcloud.save = [ ];
  };

  services.nextcloud =
    let
      package = pkgs.nextcloud31;
    in
    {
      enable = true;
      hostName = domainName;
      inherit package;
      https = true;
      database.createLocally = true;
      config = {
        dbtype = "mysql";
        adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
        adminuser = "admin";
      };
      settings = {
        trusted_domains = extraDomainNames;
        default_phone_region = "DE";
      };
      configureRedis = true;
      home = home;
      secretFile = config.sops.secrets.nextcloud-secrets.path;
      extraApps = {
        inherit (package.packages.apps) calendar;
      };
    };

  services.nginx.virtualHosts.${domainName} = {
    forceSSL = true;
    useACMEHost = config.wat.KoMa.nginx.useACMEHost;
    serverAliases = extraDomainNames;
    locations = mapAttrs' (
      link: target: nameValuePair "/${link}" { return = "301 https://${domainName}${target}"; }
    ) shortlinks;
  };
}
