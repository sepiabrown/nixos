{ config, pkgs, ... }:

with pkgs.lib;

let
  inherit (pkgs.lib) mkOption mkIf optionals literalExample mkForce;
  cfgwM = config.services.xserver.windowManager.xmonad;
  xmonad = pkgs.xmonad-with-packages.override {
    ghcWithPackages = cfgwM.haskellPackages.ghcWithPackages;
    packages = self: cfgwM.extraPackages self ++
                     optionals cfgwM.enableContribAndExtras
                     [ self.xmonad-contrib self.xmonad-extras ];
  };
  xmonadBin = pkgs.writers.writeHaskell "xmonad" {
   ghc = cfgwM.haskellPackages.ghc;
    libraries = [ cfgwM.haskellPackages.xmonad ] ++
                cfgwM.extraPackages cfgwM.haskellPackages ++
                optionals cfgwM.enableContribAndExtras
                (with cfgwM.haskellPackages; [ xmonad-contrib xmonad-extras ]);
  } cfgwM.config;

  addToXDGDirs = p: ''
    if [ -d "${p}/share/gsettings-schemas/${p.name}" ]; then
      export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${p}/share/gsettings-schemas/${p.name}
    fi

    if [ -d "${p}/lib/girepository-1.0" ]; then
      export GI_TYPELIB_PATH=$GI_TYPELIB_PATH''${GI_TYPELIB_PATH:+:}${p}/lib/girepository-1.0
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${p}/lib
    fi
  '';

  xcfg = config.services.xserver;
  cfgdM = xcfg.desktopManager.mate;
  cfg = config.services.xserver;
  xorg = pkgs.xorg;

  dmDefault = cfg.desktopManager.default;
  # fallback default for cases when only default wm is set
  dmFallbackDefault = if dmDefault != null then dmDefault else "none";
  wmDefault = cfg.windowManager.default;

  defaultSessionFromLegacyOptions = dmFallbackDefault + optionalString (wmDefault != null && wmDefault != "none") "+${wmDefault}";
  in
  { 
    services.xserver = {
      windowManager.session = mkForce [{
        name = "xmonad";
        start = if (cfgwM.config != null) then ''
          ${xmonadBin} &
          waitPID = $!
        '' else ''
        systemd-cat -t xmonad ${xmonad}/bin/xmonad &
          waitPID = $!
        '';
      }];
      desktopManager.session = mkForce [{
        name = "mate";
        bgSupport = true;
        export = ''
          export XDG_MENU_PREFIX="mate-"

          # Let caja find extensions
          export CAJA_EXTENSION_DIRS="$CAJA_EXTENSION_DIRS''${CAJA_EXTENSION_DIRS:+:}${config.system.path}/lib/caja/extensions-2.0"

          # Let caja extensions find gsettings schemas
          ${concatMapStrings (p: ''
            if [ -d "${p}/lib/caja/extensions-2.0" ]; then
              ${addToXDGDirs p}
            fi
            '')
            config.environment.systemPackages
          }

          # Let mate-panel find applets
          export MATE_PANEL_APPLETS_DIR="$MATE_PANEL_APPLETS_DIR''${MATE_PANEL_APPLETS_DIR:+:}${config.system.path}/share/mate-panel/applets"
          export MATE_PANEL_EXTRA_MODULES="$MATE_PANEL_EXTRA_MODULES''${MATE_PANEL_EXTRA_MODULES:+:}${config.system.path}/lib/mate-panel/applets"

          # Add mate-control-center paths to some XDG variables because its schemas are needed by mate-settings-daemon, and mate-settings-daemon is a dependency for mate-control-center (that is, they are mutually recursive)
          ${addToXDGDirs pkgs.mate.mate-control-center}
        '';

        start = ''
          ${pkgs.mate.mate-session-manager}/bin/mate-session ${optionalString cfgdM.debug "--debug"} &
          waitPID=$!
        '';
      }];
      displayManager.sessionPackages =
      let
        dms = filter (s: s.manage == "desktop") cfg.displayManager.session;
        wms = filter (s: s.manage == "window") cfg.displayManager.session;

        # Script responsible for starting the window manager and the desktop manager.
        xsession = dm: wm: pkgs.writeScript "xsession" ''
          #! ${pkgs.bash}/bin/bash

          # Legacy session script used to construct .desktop files from
          # `services.xserver.displayManager.session` entries. Called from
          # `sessionWrapper`.
          
          ${dm.export}

          # Start the window manager.
          ${wm.start}

          # Start the desktop manager.
          ${dm.start}

          ${optionalString cfg.updateDbusEnvironment ''
            ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
          ''}

          test -n "$waitPID" && wait "$waitPID"

          ${config.systemd.package}/bin/systemctl --user stop graphical-session.target

          exit 0
        '';
      in
        # We will generate every possible pair of WM and DM.
        concatLists (
          crossLists
            (dm: wm: let
              sessionName = "${dm.name}${optionalString (wm.name != "none") ("+" + wm.name)}";
              script = xsession dm wm;
            in
              optional (dm.name != "none" || wm.name != "none")
                (pkgs.writeTextFile {
                  name = "${sessionName}-xsession";
                  destination = "/share/xsessions/${sessionName}.desktop";
                  # Desktop Entry Specification:
                  # - https://standards.freedesktop.org/desktop-entry-spec/latest/
                  # - https://standards.freedesktop.org/desktop-entry-spec/latest/ar01s06.html
                  text = ''
                    [Desktop Entry]
                    Version=1.0
                    Type=XSession
                    TryExec=${script}
                    Exec=${script}
                    Name=${sessionName}
                    DesktopNames=${sessionName}
                  '';
                } // {
                  providedSessions = [ sessionName ];
                })
            )
            [dms wms]
        );  
    };
  }
