{ mkModule, config, pkgs, lib, liftToNamespace, ... }:

with lib;

mkModule {
  options = cfg:
    liftToNamespace {
      serverName = mkOption {
        description = "Server name for the synapse server";
        type = types.str;
      };

      domain = mkOption {
        description = "domain name for the synapse server";
        type = types.str;
      };

      port = mkOption {
        description = "Port number to listen on";
        type = types.port;
        default = 8008;
      };
    };

  config = cfg:
    let
      clientConfig = {
        "m.homeserver".base_url = "https://${cfg.serverName}";
        "m.identity_server" = { };
      };
      serverConfig."m.server" =
        "${config.services.matrix-synapse.settings.server_name}:443";

      mkWellKnown = data: ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON data}';
      '';
    in {
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      services = {
        matrix-synapse = {
          enable = true;
          settings = {
            server_name = cfg.serverName;
            enable_registration = false;

            listeners = [{
              port = cfg.port;
              bind_addresses = [ "::1" ];
              type = "http";
              tls = false;
              x_forwarded = true;

              resources = [{
                names = [ "client" "federation" ];
                compress = true;
              }];
            }];
          };
        };

        postgresql = {
          enable = true;
          initialScript = pkgs.writeText "synapse-init.sql" ''
            CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
            CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
              TEMPLATE template0
              LC_COLLATE = "C"
              LC_CTYPE = "C";
          '';
        };

        nginx = {
          enable = true;
          recommendedTlsSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;

          virtualHosts = {
            "${cfg.domain}" = {
              enableACME = true;
              forceSSL = true;
              locations."= /.well-known/matrix/server".extraConfig =
                mkWellKnown serverConfig;
              locations."= /.well-known/matrix/client".extraConfig =
                mkWellKnown clientConfig;
            };
            "${cfg.serverName}" = {
              enableACME = true;
              forceSSL = true;
              locations."/".extraConfig = ''
                return 404;
              '';
              locations."/_matrix".proxyPass =
                "http://[::1]:${toString cfg.port}";
              locations."/_synapse/client".proxyPass =
                "http://[::1]:${toString cfg.port}";
            };
          };
        };

        mautrix-telegram = {
          enable = true;
          environmentFile = config.sops.secrets.mautrix-env-file.path;
          settings = {
            # TODO
          };
        };
      };

      sops.secrets.mautrix-env-file = {
        mode = "0400";
        owner = "matrix-synapse";
        group = "matrix-synapse";
        sopsFile = ../secrets/matrix-bridge.yml;
      };
    };
}
