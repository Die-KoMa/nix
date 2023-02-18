{

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    komapedia = {
      url = "github:Die-KoMa/mediawiki";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wat = {
      url = "github:thelegy/wat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homemanager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yaner = {
      url = "github:thelegy/yaner";
      inputs.homemanager.follows = "homemanager";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.wat.follows = "wat";
    };

  };

  outputs = flakes@{ wat, nixpkgs, sops-nix, ... }:
    let
      inherit (nixpkgs.lib) attrValues concatLists concatStringsSep;
      sopsPGPKeyDirs = [ ./secrets/keys/users ./secrets/keys/hosts ];
      rekey = pkgs:
        pkgs.writeShellScriptBin "sops-rekey" ''
          ${pkgs.findutils}/bin/find . -type f -regextype posix-extended -regex '.*/secrets(/.*)?.ya?ml' -exec ${pkgs.sops}/bin/sops updatekeys {} \;
        '';
      withPkgs = wat.lib.withPkgsFor [ "x86_64-linux" ] nixpkgs
        [ flakes.sops-nix.overlay ];
    in wat.lib.mkWatRepo flakes ({ findModules, findMachines, ... }: {
      loadModules = concatLists [
        [
          flakes.homemanager.nixosModules.home-manager
          flakes.sops-nix.nixosModules.sops
        ]
        (attrValues flakes.komapedia.nixosModules)
        (attrValues flakes.yaner.nixosModules)
      ];
      loadOverlays = concatLists [
        (attrValues flakes.komapedia.overlays)
        [ flakes.yaner.overlay ]
      ];
      outputs = {
        apps = withPkgs (pkgs:
          let
            sops-wrapper = pkgs.writeShellScript "sops-wrapper" ''
              export sopsPGPKeyDirs="${concatStringsSep " " sopsPGPKeyDirs}"
              source ${pkgs.sops-import-keys-hook}/nix-support/setup-hook
              sopsImportKeysHook
              exec ${pkgs.sops}/bin/sops $@
            '';
          in {
            sops-rekey = {
              type = "app";
              program = "${rekey pkgs}/bin/sops-rekey";
            };
            sops = {
              type = "app";
              program = "${sops-wrapper}";
            };
          });

        devShells = withPkgs (pkgs: rec {
          sops = pkgs.mkShell {
            name = "sops";
            nativeBuildInputs = with pkgs; [
              sops-import-keys-hook
              ssh-to-pgp
              (rekey pkgs)
            ];
            inherit sopsPGPKeyDirs;
          };
          default = sops;
        });

        nixosModules = findModules [ "KoMa" ] ./modules;

        nixosConfigurations = findMachines ./machines;

      };
    });

}
