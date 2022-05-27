{ mkTrivialModule, lib, ... }: with lib;

mkTrivialModule {
  die-koma.komapedia.enable = true;

  sops.secrets.secret-key = {
    mode = "0400";
    owner = "mediawiki";
    group = config.services.nginx.group;
    path = "/var/lib/mediawiki/secret.key";
    sopsFile = ../secrets/komapedia.yml;
  };

}
