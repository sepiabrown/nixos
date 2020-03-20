{ config, pkgs, ... }:
{  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  services = {
    xserver = { 
      enable = true; 
      layout = "us";
      xkbVariant = "dvorak";
      desktopManager. mate.enable = true;
      
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        config = ''
          import XMonad
          import XMonad.Config.Mate
          main = xmonad mateConfig 
        ''; 
      };
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
    ];

  system.stateVersion = "19.09";
}
