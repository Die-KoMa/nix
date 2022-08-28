{ mkTrivialModule, config, lib, ... }:
with lib;

mkTrivialModule {
  die-koma.komapedia.enable = true;

  users.users.komapedia = {
    isSystemUser = true;
    group = "koma-services";
  };
  users.groups.koma-services = { };

  sops.secrets.secret-key = {
    mode = "0400";
    owner = "komapedia";
    group = config.services.nginx.group;
    path = "/var/lib/mediawiki/secret.key";
    sopsFile = ../secrets/komapedia.yml;
  };

}
