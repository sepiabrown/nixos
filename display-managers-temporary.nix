{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.xserver;

        dms = filter (s: s.manage == "desktop") cfg.displayManager.session;
        wms = filter (s: s.manage == "window") cfg.displayManager.session;

        # Script responsible for starting the window manager and the desktop manager.
        xsession = dm: wm: pkgs.writeScript "xsession" ''
          #! ${pkgs.bash}/bin/bash

          # Legacy session script used to construct .desktop files from
          # `services.xserver.displayManager.session` entries. Called from
          # `sessionWrapper`.
          export MYVAR=HIHI
          #export MYVAR2=HIHIHI

          # Export Desktop manager

          # Start the window manager.
          ${wm.start}
          # Start the desktop manager.
          ${dm.start}

          export MYVAR3=HIIII
          #${optionalString cfg.updateDbusEnvironment ''
          #  ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
          #''}

          #test -n "$waitPID" && wait "$waitPID"

          #${config.systemd.package}/bin/systemctl --user stop graphical-session.target

          #exit 0
        '';
      in
{        # We will generate every possible pair of WM and DM.

    config.services.xserver.displayManager.sessionPackages = mkForce (concatLists (
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
          )
        );
}        
