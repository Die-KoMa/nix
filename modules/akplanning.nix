{
  mkTrivialModule,
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  domainName = "aks.die-koma.org";
  extraDomainNames = [ ];
  home = "/data/akplanning";
  venv = "${home}/.venv";
  port = "3035";
in
mkTrivialModule {
  wat.KoMa = {
    nginx.enable = true;
    mariadb.enable = true;
  };

  sops.secrets.akplanning-secrets = {
    mode = "040)";
    owner = "akplanning";

    reloadUnits = [ "uwsgi-akplanning.service" ];

    services.nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = config.wat.KoMa.nginx.useACMEHost;
      serverAliases = extraDomainNames;
      locations."/" = {
        recommendedUwsgiSettings = true;
        uwsgiPass = "uwsgi://127.0.0.1:${port}";
      };
    };
  };
}
