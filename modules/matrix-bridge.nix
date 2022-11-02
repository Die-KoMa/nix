{ mkModule, config, pkgs, lib, liftToNamespace, ... }:

with lib;

mkModule {
  options = cfg:
    liftToNamespace {
      serverName = mkOption {
        description = "Server name for the synapse server (the actual fqdn of the server)";
        type = types.str;
      };

      domain = mkOption {
        description = "domain name for the synapse server, this is what appears in room and user id. It only needs to host .well-known";
        type = types.str;
      };

      port = mkOption {
        description = "Port number for the homeserver to listen on";
        type = types.port;
        default = 8008;
      };
      
      bridgePort = mkOption {
        description = "Port number for the bridge to listen on";
        type = types.port;
        default = 29317;
      };

      bridgeAdmin = mkOption {
        description = "The name of the admin matrix user for the bridge";
        type = types.str;
        default = "telegramAdmin";
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

      bridgeUser = "mautrix-telegram";
      bridgeGroup = "mautrix-telegram";
    in {
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      services = {
        matrix-synapse = {
          enable = true;
          settings = {
            server_name = cfg.domain;
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
            app_service_config_files = [
              # This file needs to be copied from /var/lib/mautrix-telegram/telegram-regestration.yaml
              # and the access rights needs to be fixed.
              "/var/lib/matrix-synapse/telegram-registration.yaml"
          ];
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
          ensureDatabases = [ "mautrix-telegram" ];
          ensureUsers = [
            {
              name = bridgeUser;
              ensurePermissions = { "DATABASE mautrix-telegram" = "ALL PRIVILEGES";};
            }
          ];
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
            homeserver = {
              # we could also go for https:// on port 443 and talk through nginx, but I don't
              # see any benefit in this for local communication
              address = "http://localhost:${toString cfg.port}";
              domain = cfg.domain;
            };
            appservice = {
              address = "http://localhost:${toString cfg.bridgePort}";
              tls_cert = false;
              tls_key = false;
              port = cfg.bridgePort;
              provisioning.enable = false;
              public.enable = false;
              id = "telegram";
              bot_username = "telegrambot";
              bot_displayname = "Telegram bridge bot";
              database = "postgres://localhost/mautrix-telegram";
            };
            bridge = {
              authless_portals = false;
              permissions = {
                "*" = "relaybot";
                "@${cfg.bridgeAdmin}:${cfg.domain}" = "admin";
              };
              animated_sticker = {
                target = "gif";
                convert_from_webm = false;
                args = {
                  width = 256;
                  height = 256;
                  fs = 25;
                };
              };
            };
          };
        };
      };

      systemd.services.mautrix-telegram = {
        serviceConfig = {
          User = bridgeUser;
          Group = bridgeGroup;
        
        };

        path = with pkgs; [
          lottieconverter # sadly unfree :( (tool to convert animated stickers)
        ];
      };

      sops.secrets.mautrix-env-file = {
        mode = "0400";
        owner = "matrix-synapse";
        group = "matrix-synapse";
        sopsFile = ../secrets/matrix-bridge.yml;
      };
    };
}
