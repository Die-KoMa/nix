{ mkMachine, ... }:

mkMachine { } ({ pkgs, config, ... }: {

  imports = [ ./hardware-configuration.nix ];

  wat.KoMa = {
    admins.enable = true;
    base.enable = true;
    grafana-cloud.enable = true;
    matrix-bridge = {
      enable = true;
      domain = "die-koma.org";
      serverName = "matrix.die-koma.org";
      ACMEhost = "brausefroschlg.die-koma.org";
      port = 8008;
    };

    nginx.enable = true;

    acme = {
      enable = true;
      staging = false;
      extraDomainNames = [ "matrix.die-koma.org" ];
      sopsCredentialsFile = "acme-hedns-tokens";
    };
  };

  wat.thelegy.backup = {
    enable = true;
    borgbaseRepo = "lg0ttakp";
    extraExcludes = [ "/var/lib/postgresql" ];
  };

  boot.loader = {
    timeout = 5;
    systemd-boot = {
      enable = true;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    interfaces."enp1s0".ipv4 = {
      addresses = [{
        address = "141.30.30.154";
        prefixLength = 25;
      }];
      routes = [{
        address = "0.0.0.0";
        prefixLength = 0;
        via = "141.30.30.129";
      }];
    };
    nameservers = [ "141.30.30.1" "141.76.14.1" ];
    domain = "die-koma.org";
  };

  services.sshd.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty.terminfo
    kitty.terminfo
    foot.terminfo
    htop
    git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
})
