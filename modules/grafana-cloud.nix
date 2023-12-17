{ mkModule, config, lib, liftToNamespace, ... }:
with lib;

mkModule {
  options = cfg:
    liftToNamespace {

      sopsGrafanaMetricsUrlFile = mkOption {
        type = types.str;
        default = "grafana-metrics-url";
      };

      sopsGrafanaMetricsUserFile = mkOption {
        type = types.str;
        default = "grafana-metrics-user";
      };

      sopsGrafanaMetricsPasswordFile = mkOption {
        type = types.str;
        default = "grafana-metrics-password";
      };

    };
  config = cfg: {

    sops.secrets = genAttrs [
      cfg.sopsGrafanaMetricsUrlFile
      cfg.sopsGrafanaMetricsUserFile
      cfg.sopsGrafanaMetricsPasswordFile
    ]
      (_: {
        format = "yaml";
        mode = "0600";
        restartUnits = [ "grafana-agent.service" ];
      });

    services.grafana-agent = {
      enable = true;
      extraFlags = [ "-disable-reporting" ];
      credentials = {
        METRICS_REMOTE_WRITE_URL = config.sops.secrets.${cfg.sopsGrafanaMetricsUrlFile}.path;
        METRICS_REMOTE_WRITE_USERNAME = config.sops.secrets.${cfg.sopsGrafanaMetricsUserFile}.path;
        metrics_remote_write_password = config.sops.secrets.${cfg.sopsGrafanaMetricsPasswordFile}.path;
      };
      settings = {
        metrics.global.remote_write = [{
          url = "\${METRICS_REMOTE_WRITE_URL}";
          basic_auth.username = "\${METRICS_REMOTE_WRITE_USERNAME}";
          basic_auth.password_file = "\${CREDENTIALS_DIRECTORY}/metrics_remote_write_password";
        }];
        integrations.node_exporter = {
          instance = config.networking.hostName;
          enable_collectors = [
            "systemd"
          ];
        };
      };
    };

  };
}
