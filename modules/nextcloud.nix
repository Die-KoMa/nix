
{ mkTrivialModule, config, pkgs, lib, ... }:

with lib;

let
  domainName = "cloud.die-koma.org";
  extraDomainNames = [ "51.cloud.die-koma.org" ];
  home = "/data/nextcloud";
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
    servers.nextcloud.save = [];
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
  };

}
