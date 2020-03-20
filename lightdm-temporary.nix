{ config, lib, pkgs, ... }:

with lib;

let

############################################################
############################################################
# nixpkgs/nixos/modules/services/x11/display-managers/lightdm.nix 
  xcfg = config.services.xserver;
  dmcfg = xcfg.displayManager;
  xEnv = config.systemd.services.display-manager.environment;
  cfg = dmcfg.lightdm;
  sessionData = dmcfg.sessionData;

  setSessionScript = pkgs.callPackage ./account-service-util.nix { };

  inherit (pkgs) lightdm writeScript writeText;

  # lightdm runs with clearenv(), but we need a few things in the environment for X to startup
  xserverWrapper = writeScript "xserver-wrapper"
    ''
      #! ${pkgs.bash}/bin/bash
      ${concatMapStrings (n: "export ${n}=\"${getAttr n xEnv}\"\n") (attrNames xEnv)}

      display=$(echo "$@" | xargs -n 1 | grep -P ^:\\d\$ | head -n 1 | sed s/^://)
      if [ -z "$display" ]
      then additionalArgs=":0 -logfile /var/log/X.0.log"
      else additionalArgs="-logfile /var/log/X.$display.log"
      fi

      exec ${dmcfg.xserverBin} ${toString dmcfg.xserverArgs} $additionalArgs "$@"
    '';

  usersConf = writeText "users.conf"
    ''
      [UserList]
      minimum-uid=500
      hidden-users=${concatStringsSep " " dmcfg.hiddenUsers}
      hidden-shells=/run/current-system/sw/bin/nologin
    '';

  lightdmConf = writeText "lightdm.conf"
    ''
      [LightDM]
      ${optionalString cfg.greeter.enable ''
        greeter-user = ${config.users.users.lightdm.name}
        greeters-directory = ${cfg.greeter.package}
      ''}
      sessions-directory = ${dmcfg.sessionData.desktops}/share/xsessions:${dmcfg.sessionData.desktops}/share/wayland-sessions
      ${cfg.extraConfig}

      [Seat:*]
      xserver-command = ${xserverWrapper}
      session-wrapper = ${xsessionWrapper}
      ${optionalString cfg.greeter.enable ''
        greeter-session = ${cfg.greeter.name}
      ''}
      ${optionalString cfg.autoLogin.enable ''
        autologin-user = ${cfg.autoLogin.user}
        autologin-user-timeout = ${toString cfg.autoLogin.timeout}
        autologin-session = ${sessionData.autologinSession}
      ''}
      ${optionalString (dmcfg.setupCommands != "") ''
        display-setup-script=${pkgs.writeScript "lightdm-display-setup" ''
          #!${pkgs.bash}/bin/bash
          ${dmcfg.setupCommands}
        ''}
      ''}
      ${cfg.extraSeatDefaults}
    '';

###################################################
###################################################
#  nixpkgs/nixos/modules/services/x11/display-managers/default.nix 
    cfgW = config.services.xserver;
    xorg = pkgs.xorg;
    fontconfig = config.fonts.fontconfig;
    xresourcesXft = pkgs.writeText "Xresources-Xft" ''
      ${optionalString (fontconfig.dpi != 0) ''Xft.dpi: ${toString fontconfig.dpi}''}
      Xft.antialias: ${if fontconfig.antialias then "1" else "0"}
      Xft.rgba: ${fontconfig.subpixel.rgba}
      Xft.lcdfilter: lcd${fontconfig.subpixel.lcdfilter}
      Xft.hinting: ${if fontconfig.hinting.enable then "1" else "0"}
      Xft.autohint: ${if fontconfig.hinting.autohint then "1" else "0"}
      Xft.hintstyle: hintslight
    '';

    xsessionWrapper = pkgs.writeScript "xsession-wrapper"
    ''
      #! ${pkgs.bash}/bin/bash

      # Shared environment setup for graphical sessions.

      . /etc/profile
      cd "$HOME"

      export MYVAR4=HIIIIIIIIIIIIIIIIIIIIIIIIIIii
      ${optionalString cfgW.startDbusSession ''
        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
          exec ${pkgs.dbus.dbus-launch} --exit-with-session "$0" "$@"
        fi
      ''}
      export MYVAR5=HELLLLLLLLLLLLLLLLLLLLLLL     
      ${optionalString cfgW.displayManager.job.logToJournal ''
        if [ -z "$_DID_SYSTEMD_CAT" ]; then
          export _DID_SYSTEMD_CAT=1
          exec ${config.systemd.package}/bin/systemd-cat -t xsession "$0" "$@"
        fi
      ''}
      export MYVAR6=SIX
      ${optionalString cfgW.displayManager.job.logToFile ''
        exec &> >(tee ~/.xsession-errors)
      ''}
      export MYVAR7=SEVEN
      # Start PulseAudio if enabled.
      ${optionalString (config.hardware.pulseaudio.enable) ''
        # Publish access credentials in the root window.
        if ${config.hardware.pulseaudio.package.out}/bin/pulseaudio --dump-modules | grep module-x11-publish &> /dev/null; then
          ${config.hardware.pulseaudio.package.out}/bin/pactl load-module module-x11-publish "display=$DISPLAY"
        fi
      ''}
      export MYVAR8=EIGHT

      # Tell systemd about our $DISPLAY and $XAUTHORITY.
      # This is needed by the ssh-agent unit.
      #
      # Also tell systemd about the dbus session bus address.
      # This is required by user units using the session bus.
      ${config.systemd.package}/bin/systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS

      export MYVAR9=EIGHT

      # Load X defaults. This should probably be safe on wayland too.
      ${xorg.xrdb}/bin/xrdb -merge ${xresourcesXft}
      if test -e ~/.Xresources; then
          ${xorg.xrdb}/bin/xrdb -merge ~/.Xresources
      elif test -e ~/.Xdefaults; then
          ${xorg.xrdb}/bin/xrdb -merge ~/.Xdefaults
      fi

      export MYVAR10=EIGHT
      # Speed up application start by 50-150ms according to
      # http://kdemonkey.blogspot.nl/2008/04/magic-trick.html
      rm -rf "$HOME/.compose-cache"
      mkdir "$HOME/.compose-cache"

      # Work around KDE errors when a user first logs in and
      # .local/share doesn't exist yet.
      mkdir -p "$HOME/.local/share"

      unset _DID_SYSTEMD_CAT

      export MYVAR11=EIGHT
      ${cfgW.displayManager.sessionCommands}

      export MYVAR12=EIGHT
      # Allow the user to execute commands at the beginning of the X session.
      if test -f ~/.xprofile; then
          source ~/.xprofile
      fi
      export MYVAR13=EIGHT

      # Start systemd user services for graphical sessions
      ${config.systemd.package}/bin/systemctl --user start graphical-session.target

      export MYVAR14=EIGHT
      # Allow the user to setup a custom session type.
      if test -x ~/.xsession; then
          eval exec ~/.xsession "$@"
      fi
      export MYVAR15=EIGHT

      if test "$1"; then
      export MYVAR16="$@"
          # Run the supplied session command. Remove any double quotes with eval.
          eval exec "$@"
      else
      export MYVAR17=EIGHT
          # TODO: Do we need this? Should not the session always exist?
          echo "error: unknown session $1" 1>&2
          exit 1
      fi
      export MYVAR18=EIGHT
    '';
in
{
  config.environment.etc."lightdm/lightdm.conf".source = mkForce lightdmConf;
}  
