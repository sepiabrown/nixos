# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
######################
######################
# important to not paste result of 'git diff' from terminal because in terminal, tabs may get transformed into spaces
#
# Description :
# The "suwon-keyboard-patch" file patches Caps Lock key to be Super_R.
# In xmonad, Super_R works as "M". For example "M-p" means "Super_R"(which is Caps Lock in my setting) + "p" key.
#
# To set the keyboard :
# 1. In Mate, go to System -> Preferences -> Hardware -> Keyboard
# 2. In Layouts tab, click Keyboard model
# 3. Choose the following. Vendors : Generic, Models : Generic 105-key PC
#
# Modifier Keys :
# mod1Mask = Left Alt
# mod3Mask = Right Alt
# mod4Mask = Windows
#
# File path :
# sudo find . -name "*xkeyboard*"
# /nix/store/~~longname~~-xkeyboard-config-2.31/share/X11/xkb/symbols/pc
  custom_xkeyboard_config = builtins.toFile "suwon-keyboard-patch" ''
--- a/symbols/pc
+++ b/symbols/pc
@@ -1,7 +1,8 @@
 default  partial alphanumeric_keys modifier_keys
 xkb_symbols "pc105" {
 
-    key <ESC>  {	[ Escape		]	};
+    key <ESC>  {	[ 		]	};
+    key <AE07>  {	[ L, l	]	};
 
     // The extra key on many European keyboards:
     key <LSGT> {	[ less, greater, bar, brokenbar ] };
@@ -19,16 +20,16 @@ xkb_symbols "pc105" {
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
@@ -36,7 +37,8 @@ xkb_symbols "pc105" {
     modifier_map Lock   { Caps_Lock };
     modifier_map Control{ Control_L, Control_R };
     modifier_map Mod2   { Num_Lock };
-    modifier_map Mod4   { Super_L, Super_R };
+    modifier_map Mod3   { Super_R };
+    modifier_map Mod4   { Super_L };
 
     // Fake keys for virtual<->real modifiers mapping:
     key <LVL3> {	[ ISO_Level3_Shift	]	};

--- a/symbols/us
+++ b/symbols/us
@@ -258,6 +258,8 @@
     key <AB10> { [	    z,	Z		]	};
 
     key <BKSL> { [  backslash,  bar             ]       };
+    include "kr(ralt_hangul)"
+    include "kr(rctrl_hanja)"
 };
 
 // Dvorak intl., with dead keys
  '';  
  xmonad_config = ''
import XMonad
import XMonad.Config.Mate
import XMonad.Util.EZConfig 
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
        , logHook = updatePointer (0.5, 0.5) (0, 0) <+> logHook mateConfig 
                --do 
               	--updatePointer (0.5, 0.5) (0, 0)
               	--logHook mateConfig -- : error happens with mate workspace!

        }
        `additionalKeysP`
                [ (("M-p"), spawn "dmenu_run -fn 'Droid Sans Mono-13'") 
               	, (("M-f"), spawn "firefox")
                , (("M-s"), spawn "alacritty -e /home/sepiabrown/my.rclone")
                , (("M-d"), spawn "caja")
                , (("M-z"), kill)

                ]
  ''; # incomplete xmobar option breaks mate workspace switcher. so set all or erase all

  inherit (pkgs.lib) mkOption mkIf optionals literalExample;
  cfg = config.services.xserver.windowManager.xmonad;
  xmonadBin = pkgs.writers.writeHaskell "xmonad" {
    ghc = cfg.haskellPackages.ghc;
    libraries = [ cfg.haskellPackages.xmonad ] ++
    cfg.extraPackages cfg.haskellPackages ++
    (with cfg.haskellPackages; [ xmonad-contrib xmonad-extras ]);
  } xmonad_config;
######################
######################

# sudo nixos-rebuild boot -I nixpkgs=https://releases.nixos.org/nixos/unstable/nixos-20.09pre215947.82b54d49066/nixexprs.tar.xz -p
# sudo nixos-rebuild switch -I nixpkgs=/home/sepiabrown/nixos-20.09pre215947.82b54d49066 -p

  channelRelease = "nixos-20.09pre215947.82b54d49066";  # 2020-03-06 01:53:48
  sha256 = "1ygvhl72mjwfgkag612q9b6nvh0k5dhdqsr1l84jmsjk001fqfa7";

  channelName = "unstable";
  url = "https://releases.nixos.org/nixos/${channelName}/${channelRelease}/nixexprs.tar.xz";

  #pinnedNixpkgs = "/home/sepiabrown/nixos-20.09pre215947.82b54d49066";
  pinnedNixpkgs = builtins.fetchTarball {
    inherit url sha256;
  };
in
{
  system.copySystemConfiguration = true;  

  nix.nixPath = [
    "nixpkgs=${pinnedNixpkgs}"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  programs.command-not-found = {
    enable = true;
    dbPath = "${pinnedNixpkgs}/programs.sqlite";
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./mate-temporary.nix
      #./xmonad-temporary.nix
      #./display-managers-temporary.nix
      #./lightdm-temporary.nix
    ];

  # fileSystems."/home" =
  #  { device = "/dev/disk/by-label/vivohome";
  #    fsType = "ext4";
  #  };  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

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

  i18n.inputMethod.enabled = "uim";
 
  environment.systemPackages = with pkgs; 
    let
    customR = rWrapper.override { packages = with rPackages; [ 
      foreign
      ggplot2
      dplyr
      xts
    ];};
    customRStudio = rstudioWrapper.override{ packages = with rPackages; [ 
      pacman foreign tidyverse
      ggplot2 dplyr xts
    ];};
    in
    [
    pkg-config intltool gtk-doc libtool autoconf automake 
    which gtk2 gtk3 libhangul librime libxkbcommon m17n_db m17n_lib anthy gettext qt4 qt5.qtbase librsvg libappindicator libxklavier
    gnumake
    automake
    autoconf
    
    #test
    #nimf
    #system
    samba
    samba4Full
    hplip
    ripgrep
    zip
    unzip
    nvramtool
    refind
    blueman
    networkmanager
    networkmanagerapplet
    wget
    curl
    file
    htop
    gparted
    partition-manager
    lvm2
    home-manager
    rclone
    git
    baobab # Disk Usage Analyser
    dua # Disk Usage
    duc # Disk Usage
    testdisk

    #must-need
    qt5.qtbase
    qt4
    pkg-config

    anthy

    vimHugeX
    emacs
    #emacsGit
    firefox
    chromium
    # google-chrome
    libreoffice
    alacritty
    dmenu
    # haskellPackages.dbus
    # haskellPackages.xmonad-contrib
    # haskellPackages.xmonad-extras
    # haskellPackages.xmonad
    haskellPackages.xmobar

    #document tools
    texlive.combined.scheme-full
    poppler_utils


    #dev tools
    python3
    haskellPackages.ghc

    #stat tools
    rstudio
    pandoc
    customR
    customRStudio
    #virtualbox # for SAS

    #multimedia
    vlc
    flameshot
    shutter

    capture # no sound
    simplescreenrecorder # with sound
    
    #unfree
    zoom-us
    ];

    virtualisation.virtualbox = {
      #guest = {
      #  enable =true;
      #};
      host = {
        enable = true;
        #enableExtensionPack = true;
      };
    };
    users.extraGroups.vboxusers.members = [ "sepiabrown" "root" ];
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
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
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

      # windowManager.xmonad = {
      #   enable = true;
      #   enableContribAndExtras = true;
      #   config = (xmonad_config);
      #   extraPackages = haskellPackages: [
      #     haskellPackages.xmonad-contrib
      #     haskellPackages.xmonad-extras
      #     haskellPackages.xmonad
      #   ];
      # };

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

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
         "xpdf-4.02"
    ];
  };

  nixpkgs.overlays = [
    (self: super: {
      new_xkeyboardconfig = super.xorg.xkeyboardconfig.overrideAttrs (old: {
        patches = [
          (custom_xkeyboard_config)
        ];
        #patchFlags = [ "-p2" ];
      }); 

      new_xkbcomp = super.xorg.xkbcomp.overrideAttrs (old: {
        configureFlags = "--with-xkb-config-root=${self.new_xkeyboardconfig}/share/X11/xkb";
      });

      xorg = super.xorg // {
        xorgserver = super.xorg.xorgserver.overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [
            "--with-xkb-path=${self.new_xkeyboardconfig}/share/X11/xkb"
            "--with-xkb-bin-directory=${self.new_xkbcomp}/bin"
          ];
        });
      }; # display manager keyboard

      libxklavier = super.libxklavier.overrideAttrs (old: {
        configureFlags = old.configureFlags ++ [
          "--with-xkb-base=${self.new_xkeyboardconfig}/share/X11/xkb"
          "--with-xkb-bin-base=${self.new_xkbcomp}/bin"
        ]; 
      }); # window manager keyboard

#      xkbvalidate = super.xkbvalidate.override {
#        libxkbcommon = super.libxkbcommon.override {
#          xkeyboard_config = self.xorg.new_xkeyboardconfig;
#        };
#      };

      emacs = (super.emacs.overrideAttrs(old: {
        buildInputs = old.buildInputs
          ++ [self.glib-networking];
      })).override {
        withXwidgets = true;
        withGTK3 = true;
        webkitgtk = super.webkitgtk;
      };

    })
  ];

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [ 
      anonymousPro # unfree, TrueType font set intended for source code 
      corefonts # unfree, Microsoft's TrueType core fonts for the Web has an unfree license (‘unfreeRedistributable’), refusing to evaluate.
      dejavu_fonts # unfree, A typeface family based on the Bitstream Vera fonts
      noto-fonts # Beautiful and free fonts for many languages
      freefont_ttf # GNU Free UCS Outline Fonts
      google-fonts
      inconsolata # A monospace font for both screen and print
      liberation_ttf # Liberation Fonts, replacements for Times New Roman, Arial, and Courier New
      powerline-fonts  # unfree? Oh My ZSH, agnoster fonts  
      source-code-pro
      terminus_font  # unfree, A clean fixed width font
      ttf_bitstream_vera # unfree
      ubuntu_font_family
      d2coding
    ];
  };

  
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
