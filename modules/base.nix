{
  lib,
  config,
  pkgs,
  mkTrivialModule,
  ...
}:
with lib;

mkTrivialModule {

  wat.thelegy.homeManager.enable = true;
  wat.thelegy.emergencyStorage.enable = mkDefault true;
  wat.thelegy.zsh.enable = mkDefault true;

  wat.KoMa.admins.enable = true;

  boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

  # Restore systemd default
  services.logind.killUserProcesses = mkDefault true;

  sops.defaultSopsFile = config.wat.machines.${config.networking.hostName}."secrets.yml".file;
  sops.defaultSopsFormat = "yaml";

  networking.domain = mkDefault "die-koma.org";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
    # Gruvbox tty colors
    colors = [
      "000000"
      "cc241d"
      "98971a"
      "d79921"
      "458588"
      "b16286"
      "689d6a"
      "a89984"
      "928374"
      "fb4934"
      "b8bb26"
      "fabd2f"
      "83a598"
      "d3869b"
      "8ec07c"
      "ebdbb2"
    ];
  };
  time.timeZone = "Europe/Berlin";

  boot.tmp.useTmpfs = true;

  services = {
    acpid.enable = mkDefault false;
    avahi.enable = mkDefault false;
  };

  services.openssh = {
    enable = mkDefault true;
    settings = {
      PasswordAuthentication = mkDefault false;
      KbdInteractiveAuthentication = mkDefault false;
    };
  };

  hardware.rasdaemon.enable = mkDefault true;

  programs = {
    less.enable = true;
    mtr.enable = true;
    tmux.enable = true;
  };

  environment.shellInit = ''
    PATH=~/.local/bin:$PATH
    export PATH
  '';

  documentation.man.generateCaches = mkDefault true;

  nix = {
    settings.auto-optimise-store = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    package = pkgs.nixVersions.stable;
  };

  environment.systemPackages = with pkgs; [
    alacritty.terminfo
    foot.terminfo
    git
    gnupg
    htop
    inxi-full
    kitty.terminfo
    lazygit
    lm_sensors
    neovim-thelegy
    reptyr
    ripgrep
    tig
    w3m
  ];
}
