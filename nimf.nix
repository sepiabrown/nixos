{ config, pkgs, ... }:
let
  pinnedNixpkgs = "/home/sepiabrown/nixos-20.09pre215947.82b54d49066";
in
{  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nix.nixPath = [
    "nixpkgs=${pinnedNixpkgs}"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  programs.command-not-found = {
    enable = true;
    dbPath = "${pinnedNixpkgs}/programs.sqlite";
  };

  services = {
    xserver = { 
      enable = true; 
      layout = "us";
      xkbVariant = "dvorak";
      desktopManager. mate.enable = true;
      
      #windowManager.xmonad = {
      #  enable = true;
      #  enableContribAndExtras = true;
      #  config = ''
      #    import XMonad
      #    import XMonad.Config.Mate
      #    main = xmonad mateConfig 
      #  ''; 
      #};
    };  
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;
 
  networking.hostName = "test";
  networking.networkmanager.enable = true; 
  environment.systemPackages = with pkgs; 
  [
    vimHugeX
    firefox
    lvm2
    networkmanager
    htop
    flameshot
    nimf
  ];

  users = {
    users.sepiabrown = {
      isNormalUser = true;
      home = "/home/sepiabrown";
      hashedPassword = "$6$U4rwuO8Gycc$lOleYt0NLgOoUj2FrROHM1qu01joT1RhM2FLgnhqZGtNd0ALnbBY5DIzMH0EY1WFs2SEK4o8Z1H35M8nKpguP0";
      extraGroups = [ 
        "wheel"
        "networkmanager"
      ]; # Enable ‘sudo’ for the user.
    };
  };

  nix.allowedUsers = [ "sepiabrown" ];
  security.sudo.extraConfig = ''
    %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  '';

  system.copySystemConfiguration = true;
  system.stateVersion = "19.09";
}
