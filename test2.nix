{ config, pkgs, ... }:
let
  inherit (pkgs.lib) mkOption mkIf optionals literalExample;
  cfg = config.services.xserver.windowManager.xmonad;
  xmonadBin = pkgs.writers.writeHaskell "xmonad" {
    ghc = cfg.haskellPackages.ghc;
    libraries = [ cfg.haskellPackages.xmonad ] ++
                cfg.extraPackages cfg.haskellPackages ++
                (with cfg.haskellPackages; [ xmonad-contrib xmonad-extras ]);
  } ''

import XMonad
import XMonad.Config.Mate
import XMonad.Hooks.DynamicLog

-- The main function.
main = xmonad mateConfig 
        { borderWidth        = 2
        , terminal           = "mate-terminal" --"alacritty"
        }
'';
in
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
      displayManager.sessionCommands = ''
        ${xmonadBin} --replace &
      '';
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
