{ mkModule
, config
, lib
, pkgs
, liftToNamespace
, ... }:
with lib;

mkModule {
  options = cfg: liftToNamespace {

    staging = mkOption {
      type = types.bool;
      default = true;
    };

    defaultCertName = mkOption {
      type = types.str;
      default = config.networking.fqdn;
    };

    extraDomainNames = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    sopsCredentialsFile = mkOption {
      type = types.str;
      default = "acme-credentials-file";
    };

    reloadUnits = mkOption {
      type = types.listOf types.str;
      default = [];
    };

  };
  config = cfg: {

    sops.secrets.${cfg.sopsCredentialsFile} = {
      format = "yaml";
      mode = "0600";
      owner = "acme";
      restartUnits = [ "acme-${cfg.defaultCertName}.service" ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.server = mkIf (cfg.staging) "https://acme-staging-v02.api.letsencrypt.org/directory";
      defaults.email = "homepage@die-koma.org";
      preliminarySelfsigned = false;
      certs.${cfg.defaultCertName} = {
        inherit (cfg) extraDomainNames;
        dnsProvider = "desec";
        credentialsFile = pkgs.writeText "acme-env" ''
          DESEC_TOKEN_FILE=${config.sops.secrets.${cfg.sopsCredentialsFile}.path}
          LEGO_EXPERIMENTAL_CNAME_SUPPORT=true
          DESEC_PROPAGATION_TIMEOUT=300
        '';
        postRun = mkIf (length cfg.reloadUnits > 0) ''
          systemctl reload-or-restart ${concatStringsSep " " cfg.reloadUnits}
        '';
      };
    };

  };
}
