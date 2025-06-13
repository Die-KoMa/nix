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

      sopsGrafanaMetricsEnvFile = mkOption {
        type = types.str;
        default = "grafana-metrics-env";
      };

      sopsGrafanaMetricsPasswordFile = mkOption {
        type = types.str;
        default = "grafana-metrics-password";
      };
    };
  config = cfg: {

    sops.secrets =
      genAttrs
        [
          cfg.sopsGrafanaMetricsEnvFile
          cfg.sopsGrafanaMetricsPasswordFile
        ]
        (_: {
          format = "yaml";
          mode = "0600";
          restartUnits = [ "alloy.service" ];
        });

    services.alloy = {
      enable = true;
      configPath = "/etc/alloy";
    };

    environment.etc."alloy/config.alloy".text = ''
      prometheus.remote_write "default" {
        endpoint {
          url = string.format("%s", sys.env("METRICS_REMOTE_WRITE_URL"))

          basic_auth {
            username = string.format("%s", sys.env("METRICS_REMOTE_WRITE_USERNAME"))
            password_file = string.format("%s/METRICS_REMOTE_WRITE_PASSWORD", sys.env("CREDENTIALS_DIRECTORY"))
          }
        }
      }
    '';

    environment.etc."alloy/self-exporter.alloy".text = ''
      prometheus.exporter.self "self" {
      }

      prometheus.scrape "self" {
        targets = prometheus.exporter.self.self.targets
        forward_to = [prometheus.remote_write.default.receiver]
      }
    '';

    environment.etc."alloy/unix-exporter.alloy".text = ''
      prometheus.exporter.unix "self" {
        enable_collectors = [
          "systemd",
        ]
      }

      prometheus.scrape "unix" {
        targets = prometheus.exporter.unix.self.targets
        forward_to = [prometheus.remote_write.default.receiver]
      }
    '';

    systemd.services.alloy.serviceConfig = {
      EnvironmentFile = config.sops.secrets.${cfg.sopsGrafanaMetricsEnvFile}.path;
      LoadCredential = [
        "METRICS_REMOTE_WRITE_PASSWORD:${config.sops.secrets.${cfg.sopsGrafanaMetricsPasswordFile}.path}"
      ];
    };
  };
}
