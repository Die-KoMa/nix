{ mkMachine, ... }:

mkMachine { } ({ pkgs, lib, ... }: {

  imports = [ ./hardware-configuration.nix ];

  wat.KoMa = {
    admins.enable = true;
    #komapedia.enable = true;
    matrix-bridge = {
      enable = true;
      domain = "die-koma.org";
      serverName = "matrix.die-koma.org";
      ACMEhost = "brausefrosch.die-koma.org";
      port = 8008;
    };
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
  };

  services.sshd.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty.terminfo
    kitty.terminfo
    foot.terminfo
    htop
    git
  ];

  sops.secrets.desec_token = {
    owner = "acme";
    sopsFile = ../../secrets/brausefrosch.yml;
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      email = "homepage@die-koma.org";
    };
    preliminarySelfsigned = false;
    certs = {
      "brausefrosch.die-koma.org" = {
        extraDomainNames = [
          "brausefrosch.die-koma.org"
          "new.die-koma.org"
          "matrix.die-koma.org"
        ];
        dnsProvider = "desec";
        credentialsFile = pkgs.writeText "acme-env" ''
          DESEC_TOKEN_FILE=/run/secrets/desec_token
          LEGO_EXPERIMENTAL_CNAME_SUPPORT=true
          DESEC_PROPAGATION_TIMEOUT=300
        '';
        group = "nginx";
        postRun = ''
          systemctl start --failed nginx.service
          systemctl reload nginx.service
        '';
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      default = {
        default = true;
        forceSSL = true;
        useACMEHost = "brausefrosch.die-koma.org";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  nix = {
    autoOptimiseStore = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    package = pkgs.nixFlakes;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
})
