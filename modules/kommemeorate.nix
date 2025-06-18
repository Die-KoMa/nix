{
  mkModule,
  liftToNamespace,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkOption types;
in
mkModule {
  options =
    cfg:
    liftToNamespace {
      secrets = mkOption {
        default = { };
        type = types.submodule {
          options = {
            sopsKommemeorateTelegramApiIdFile = mkOption {
              type = types.str;
              default = "kommemeorate-telegram-api-id";
            };
            sopsKommemeorateTelegramApiHashFile = mkOption {
              type = types.str;
              default = "kommemeorate-telegram-api-hash";
            };
            sopsKommemeorateTelegramBotPasswordFile = mkOption {
              type = types.str;
              default = "kommemeorate-telegram-bot-password";
            };
            sopsKommemeorateMatrixPasswordFile = mkOption {
              type = types.str;
              default = "kommemeorate-matrix-password";
            };
          };
        };
      };

      telegramGroups = mkOption {
        description = "telegram groups to collect memes from";
        type = types.attrsOf types.int;
      };

      matrix = mkOption {
        default = { };
        type = types.submodule {
          options = {
            homeserver = mkOption {
              description = "matrix homeserver";
              type = types.str;
              default = "https://matrix.die-koma.org";
            };

            username = mkOption {
              description = "matrix username";
              type = types.str;
              default = "@kommemeorate:die-koma.org";
            };

            rooms = mkOption {
              description = "matrix rooms to collect memes from";
              type = types.attrsOf types.str;
              default = { };
            };
          };
        };
      };

      storagePath = mkOption {
        description = "where to store the memes";
        type = types.path;
      };

      databaseUrl = mkOption {
        description = "database for meme metadata";
        type = types.str;
      };
    };

  config = cfg: {
    sops.secrets =
      lib.genAttrs
        [
          cfg.secrets.sopsKommemeorateTelegramApiIdFile
          cfg.secrets.sopsKommemeorateTelegramApiHashFile
          cfg.secrets.sopsKommemeorateTelegramBotPasswordFile
          cfg.secrets.sopsKommemeorateMatrixPasswordFile
        ]
        (name: {
          format = "yaml";
          mode = "0600";
          owner = "kommemeorate";
          group = "kommemeorate";
          reloadUnits = [ "kommemeorate.service" ];
        });

    users = {
      users.kommemeorate = {
        isSystemUser = true;
        group = "kommemeorate";
      };

      groups.kommemeorate = { };
    };

    services.postgresql = {
      ensureUsers = [
        {
          name = "kommemeorate";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "kommemeorate" ];
    };

    die-koma.kommemeorate = {
      enable = true;

      telegram = {
        apiIdFile = config.sops.secrets.${cfg.secrets.sopsKommemeorateTelegramApiIdFile}.path;
        apiHashFile = config.sops.secrets.${cfg.secrets.sopsKommemeorateTelegramApiHashFile}.path;
        passwordFile = config.sops.secrets.${cfg.secrets.sopsKommemeorateTelegramBotPasswordFile}.path;
        groups = lib.mapAttrsToList (name: id: { inherit name id; }) cfg.telegramGroups;
      };

      matrix = {
        inherit (cfg.matrix) homeserver username;
        passwordFile = config.sops.secrets.${cfg.secrets.sopsKommemeorateMatrixPasswordFile}.path;
        rooms = lib.mapAttrsToList (name: address: { inherit name address; }) cfg.matrix.rooms;
      };

      storage.path = cfg.storagePath;
      database.url = cfg.databaseUrl;
      user = "kommemeorate";
      group = "kommemeorate";
    };

    wat.KoMa.postgresql.enable = true;
  };
}
