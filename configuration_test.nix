# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
######################
######################
# important to not paste result of 'git diff' from terminal
# because in terminal, tabs may get transformed into spaces
  custom_xkeyboard_config = builtins.toFile "suwon-keyboard-patch" ''
diff --git a/symbols/pc b/symbols/pc
index 0199713..6d396aa 100644
--- a/symbols/pc
+++ b/symbols/pc
@@ -1,7 +1,7 @@
 default  partial alphanumeric_keys modifier_keys
 xkb_symbols "pc105" {
 
-    key <ESC>  {	[ Escape		]	};
+    key <ESC>  {	[ 		]	};
 
     // The extra key on many European keyboards:
     key <LSGT> {	[ less, greater, bar, brokenbar ] };
@@ -19,16 +19,16 @@ xkb_symbols "pc105" {
     key  <TAB> {	[ Tab,	ISO_Left_Tab	]	};
     key <RTRN> {	[ Return		]	};
 
-    key <CAPS> {	[ Caps_Lock		]	};
+    key <CAPS> {	[ Super_R		]	};
     key <NMLK> {	[ Num_Lock 		]	};
 
     key <LFSH> {	[ Shift_L		]	};
     key <LCTL> {	[ Control_L		]	};
-    key <LWIN> {	[ Super_L		]	};
+    key <LWIN> {	[ Caps_Lock		]	};
 
-    key <RTSH> {	[ Shift_R		]	};
+    key <RTSH> {	[ Escape		]	};
     key <RCTL> {	[ Control_R		]	};
-    key <RWIN> {	[ Super_R		]	};
+    key <RWIN> {	[ NoSymbol		]	};
     key <MENU> {	[ Menu			]	};
 
     // Beginning of modifier mappings.
@@ -36,7 +36,8 @@ xkb_symbols "pc105" {
     modifier_map Lock   { Caps_Lock };
     modifier_map Control{ Control_L, Control_R };
     modifier_map Mod2   { Num_Lock };
-    modifier_map Mod4   { Super_L, Super_R };
+    modifier_map Mod3   { Super_R };
+    modifier_map Mod4   { Super_L };
 
     // Fake keys for virtual<->real modifiers mapping:
     key <LVL3> {	[ ISO_Level3_Shift	]	};
  '';  
  xmonad_config = ''
import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Mate
import XMonad.Util.EZConfig 
--import XMonad.Util.Dmenu
import XMonad.Hooks.DynamicLog
import XMonad.Prompt.Shell
import XMonad.Actions.UpdatePointer

-- The main function.
main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

-- Command to launch the bar.
myBar = "xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">"}

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = mod3Mask} = (mod3Mask, xK_b)

-- Main configuration, override the defaults to your liking.
myConfig = mateConfig 
        { borderWidth        = 2
        , terminal           = "mate-terminal" --"alacritty"
        , normalBorderColor  = "#cccccc"
        , focusedBorderColor = "#cd8b00" 
        , modMask = mod3Mask 
        , focusFollowsMouse = False
        --, workspaces = ["web","2","3","4","5","6","7","8","9","10","11"]
        , logHook = updatePointer (0.5, 0.5) (0, 0) <+> logHook desktopConfig 
                --do 
               	--updatePointer (0.5, 0.5) (0, 0)
               	--logHook mateConfig -- : error happens with mate workspace!

        }
        `additionalKeysP`
                [ (("M-p"), spawn "dmenu_run -fn 'Droid Sans Mono-13'") 
               	, (("M-f"), spawn "firefox")
               	, (("M-s"), spawn "alacritty -e my.rclone")
                , (("M-z"), kill)

                ]
  ''; # incomplete xmobar option breaks mate workspace switcher. so set all or erase all

  inherit (pkgs.lib) mkOption mkIf optionals literalExample;
  cfg = config.services.xserver.windowManager.xmonad;
  xmonadBin = pkgs.writers.writeHaskell "xmonad2" {
    ghc = cfg.haskellPackages.ghc;
    libraries = [ cfg.haskellPackages.xmonad ] ++
                cfg.extraPackages cfg.haskellPackages ++
                optionals cfg.enableContribAndExtras
                (with cfg.haskellPackages; [ xmonad-contrib xmonad-extras ]);
  } xmonad_config;
######################
######################

# sudo nixos-rebuild boot -p '20031619_gvfs__test' -I nixpkgs=https://releases.nixos.org/nixos/unstable/nixos-20.09pre215947.82b54d49066/nixexprs.tar.xz 
# sudo nixos-rebuild switch -p '20031619_gvfs__test' -I nixpkgs=/home/sepiabrown/nixos-20.09pre215947.82b54d49066

in
{
  system.copySystemConfiguration = true;  

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # fileSystems."/home" =
  #  { device = "/dev/disk/by-label/vivohome";
  #    fsType = "ext4";
  #  };  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "suwon-nix"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;   # wpa_spplicant and networkmanager collide
    packages = [
#????????????????????????????????????
      pkgs.networkmanager-l2tp
    ];
  };

  networking.extraHosts = ''
    209.51.188.89 elpa.gnu.org
  '';
#????????????????????????????????????

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
 
  environment.systemPackages = with pkgs; 
    let
      R-with-my-packages = rWrapper.override { packages = with rPackages; [ 
        ggplot2
        dplyr
        xts
      ];};
    in
    [
    #system
    vimHugeX
    firefox
    lvm2
    networkmanager
    htop
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  powerManagement.enable = true;
  hardware.enableRedistributableFirmware = true;
  # hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    zeroconf.discovery.enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  
  #  sound.mediaKeys = {
  #    enable = true;
  #    volumeStep = "5%";
  #  };


  # hardware.opengl.driSupport32Bit = true;
  # hardware.brightnessctl.enable = true;
  # services.illum.enable = true;
  
  # List services that you want to enable:
  services = {
    openssh.enable = true; # Enable the OpenSSH daemon.
    blueman.enable = true;
    xl2tpd.enable = true;
    xserver = { 
      enable = true; # Enable the X11 windowing system.
      displayManager.defaultSession = "mate";
      libinput.enable = true; # Enable touchpad support.
      layout = "us";
      xkbVariant = "dvorak";
      desktopManager = {
        mate.enable = true;
        # default = "mate"; # deprecated
      };

      # Choose mate, not mate+xmonad! or gvfsd-trash and caja hell begins
      # .xprofile :
      # xmonad --replace &
      # export XPROFILECHECK=1
      # exec mate-session

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        config = (xmonad_config);
        extraPackages = haskellPackages: [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
      };

      displayManager.sessionCommands = ''
        export CUSTOMXMONAD=${xmonadBin}
        ${xmonadBin} --replace &
      '';
    };  

  #displayManager.lightdm.autoLogin = {
  #enable = true;
  #user = "sepiabrown";
  };

  console.useXkbConfig = true;

  nixpkgs.config.allowUnfree = true;

  environment = {  
    etc."ipsec.secrets".text = ''
      include ipsec.d/ipsec.nm-l2tp.secrets
    '';
    #variables = {
    #  TERMINAL = [ "mate-terminal" ];
    #  # OH_MY_ZSH = [ "${pkgs.oh-my-zsh}/share/oh-my-zsh" ];
    #};
  };

  programs.vim.defaultEditor = true;
  # programs.zsh
  # virtualisation.docker


  # Define a user account. Don't forget to set a password with ‘passwd’.
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
  # system.autoUpgrade.channel = true;
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
