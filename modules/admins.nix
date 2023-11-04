{ mkTrivialModule, lib, ... }:
with lib;

let

  admins = {

    beinke = {
      hashedPassword =
        "$6$rounds=424242$4XeOOipFMr154yFt$duKTFu2mSR9LnrGILjgumlxl8FltvCo9RBjhWi1N56avEVaAJym3LFlw3y2.JMCVYAO2ZpK75eF7B/7cSu5rR0";
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCC4cFL1xcZOsIzXg1b/M4b89ofMKErNhg9s+0NdBVC beinke@th1"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPiDlbJKEnmM2G8Br8Yj2M+cIEyTXqP4qJM6+gBQ1pm beinke@sirrah"
      ];
    };

    mmarx = {
      hashedPassword =
        "$6$rounds=424242$If29MAgIOTOY9$mi2kyooy/lzIR6F9YPQo0bnkfjpBIdFswHbwgn2yxfqAnOwgni7TLGGk2HCUldG0T1Z7Qu9mhYaNdm0EJkJl6.";
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB8FCFThGOBFw6kGprgqlLU6bylvanxmZtgBUAS2sJcT mmarx@korenchkin"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM97cpt3/r5P8qD5j5zk3XOs3NJO4tTQPAqef33xBYL mmarx@delacroix"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQAh9/kfa4v5102PhJ4EBqFS5aTjbYTgPaGAr6lJ9Hs mmarx@bloome"
      ];
    };

    nerf = {
      hashedPassword =
        "$6$rounds=424242$FaEtIXMUScxgAYyF$Fl8GbPFgiEv.1iwrhtVpTixG1BTJys3aIfLyTzocQYZV4JymrYEXtnyCTURmVDe8stxbxgDutmtlyElfn1DQc/";
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGDe2GHC3ZUxwxWawLlKa3DRSHG1Cer5JL3ctc3GcRn nerf@nerflap2"
      ];
    };

    bender = {
      hashedPassword =
        "$6$rounds=424242$H7lG3mtgKwx$xM1FQihMtl9MnN2CRLvoqdk1miYiNFELB6paHjBHAa0qzvf1eP4N7cLZ3W5Oh0o.LfjLZGk19LFd0gQS/R9YU/";
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPVuQrWWKRFVlFfiwagVNOys0mB+8ZS53Ku6XVXHzHN8 kimbtech@desktop"
      ];
    };
  };

  mkAdmin = name:
    { hashedPassword, keys }: {
      root.openssh.authorizedKeys.keys = keys;
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

in mkTrivialModule {

  users = {
    mutableUsers = false;
    users = mkMerge (mapAttrsToList mkAdmin admins);
  };

}
