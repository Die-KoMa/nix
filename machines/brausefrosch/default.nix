{ mkMachine, ... }:

mkMachine { }
  ({ pkgs, lib, ... }: {

    imports = [
      ./hardware-configuration.nix
    ];

    boot.loader = {
      timeout = 5;
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };

    users = {
      mutableUsers = false;
      users =
        let
          mkAdmin = { name, hashedPassword, keys }: {
            "${name}" = {
              isNormalUser = true;
              createHome = true;
              extraGroups = [ "wheel" ];
              group = "users";
              home = "/home/${name}";
              openssh.authorizedKeys = { inherit keys; };
              inherit hashedPassword;
            };
          };
          getKeys = { keys, ... }: keys;
          admins = [{
            name = "mmarx";
            hashedPassword = "$6$rounds=424242$If29MAgIOTOY9$mi2kyooy/lzIR6F9YPQo0bnkfjpBIdFswHbwgn2yxfqAnOwgni7TLGGk2HCUldG0T1Z7Qu9mhYaNdm0EJkJl6.";
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB8FCFThGOBFw6kGprgqlLU6bylvanxmZtgBUAS2sJcT mmarx@korenchkin"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM97cpt3/r5P8qD5j5zk3XOs3NJO4tTQPAqef33xBYL mmarx@delacroix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQAh9/kfa4v5102PhJ4EBqFS5aTjbYTgPaGAr6lJ9Hs mmarx@bloome"
            ];
          }
            {
              name = "beinke";
              hashedPassword = "$6$rounds=424242$4XeOOipFMr154yFt$duKTFu2mSR9LnrGILjgumlxl8FltvCo9RBjhWi1N56avEVaAJym3LFlw3y2.JMCVYAO2ZpK75eF7B/7cSu5rR0";
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCC4cFL1xcZOsIzXg1b/M4b89ofMKErNhg9s+0NdBVC beinke@th1"
              ];
            }];
        in
        lib.mkMerge ((map mkAdmin admins) ++ [{
          root.openssh.authorizedKeys.keys = lib.concatMap getKeys admins;
        }]);
    };

    networking = {
      hostName = "brausefrosch";
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
      nameservers = [
        "141.30.30.1"
        "141.76.14.1"
      ];
    };

    services.sshd.enable = true;

    environment.systemPackages = with pkgs; [
      alacritty.terminfo
      kitty.terminfo
      htop
      git
    ];

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
