{
  mkModule,
  config,
  lib,
  liftToNamespace,
  ...
}:

with lib;

mkModule {
  options =
    cfg:
    liftToNamespace {
      managementPort = mkOption {
        description = "Port number for the management to listen on";
        type = types.port;
        default = 8009;
      };

      reportDomain = mkOption {
        description = "domain name for use in Delivery Status Notifications";
        type = types.str;
      };
    };

  config =
    cfg:
    let
      adminSecret = "stalwart-mail-admin";
      managementURL = "[::1]:${toString cfg.managementPort}";
    in
    {
      services.stalwart-mail = {
        enable = true;
        openFirewall = true;
        settings = {
          server = {
            hostname = config.networking.fqdn;
            tls = {
              enable = true;
            };
            listener = {
              smtp = {
                protocol = "smtp";
                bind = "[::]:25";
              };
              submission = {
                protocol = "smtp";
                bind = "[::]:465";
                tls.implicit = true;
              };
              imaps = {
                protocol = "imap";
                bind = "[::]:993";
                tls.implicit = true;
              };
              management = {
                bind = managementURL;
                protocol = "http";
              };
              managesieve = {
                bind = "[::]:4190";
                protocol = "managesieve";
              };
            };
          };
          report.domain = cfg.reportDomain;
          lookup.default.hostname = config.networking.fqdn;
          certificate.default =
            let
              acmePath = name: "%{file:/var/lib/acme/${config.wat.KoMa.acme.defaultCertName}/${name}}%";
            in
            {
              cert = acmePath "cert.pem";
              private-key = acmePath "key.pem";
              default = true;
            };
          authentication.fallback-admin = {
            user = "admin";
            secret = "%{file:${config.sops.secrets.${adminSecret}.path}}%";
          };
        };
      };

      users.users.stalwart-mail.extraGroups = [ "acme" ];

      sops.secrets.${adminSecret} = {
        format = "yaml";
        mode = "0600";
        owner = "stalwart-mail";
      };

      systemd.services.stalwart-mail = {
        reload =
          let
            stalwart-cli = "${config.services.stalwart-mail.package}/bin/stalwart-cli";
          in
          ''
            export URL=http://${managementURL}
            export CREDENTIALS=$(cat ${config.sops.secrets.${adminSecret}.path})
            ${stalwart-cli} server reload-config
            ${stalwart-cli} server reload-certificates
          '';
        restartIfChanged = true;
      };

      wat.KoMa.acme.reloadUnits = [ "stalwart-mail.service" ];

    };
}
