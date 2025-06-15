{
  mkModule,
  config,
  liftToNamespace,
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
      onCalendar = mkOption {
        description = "When to run aksync";
        type = types.listOf types.str;
      };

      sopsAksyncPasswordFile = mkOption {
        type = types.str;
        default = "aksync-bot-password";
      };
    };

  config = cfg: {
    sops.secrets.${cfg.sopsAksyncPasswordFile} = {
      format = "yaml";
      mode = "0600";
      restartUnits = [ "aksync.service" ];
    };

    die-koma.aksync = {
      enable = true;
      onCalendar = cfg.onCalendar;

      passwordFile = config.sops.secrets.${cfg.sopsAksyncPasswordFile}.path;
    };
  };
}
