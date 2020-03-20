{ config, lib, pkgs, ... }:
	
with lib;


let

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
  cfg = xcfg.desktopManager.mate;

in
{
    config.services.xserver.desktopManager.session = mkForce [{
      name = "mate";
      bgSupport = true;
      export = ''
        export XDG_MENU_PREFIX=mate-

        # Let caja find extensions
        export CAJA_EXTENSION_DIRS=$CAJA_EXTENSION_DIRS''${CAJA_EXTENSION_DIRS:+:}${config.system.path}/lib/caja/extensions-2.0

        # Let caja extensions find gsettings schemas
        ${concatMapStrings (p: ''
          if [ -d "${p}/lib/caja/extensions-2.0" ]; then
            ${addToXDGDirs p}
          fi
          '')
          config.environment.systemPackages
        }

        # Let mate-panel find applets
        export MATE_PANEL_APPLETS_DIR=$MATE_PANEL_APPLETS_DIR''${MATE_PANEL_APPLETS_DIR:+:}${config.system.path}/share/mate-panel/applets
        export MATE_PANEL_EXTRA_MODULES=$MATE_PANEL_EXTRA_MODULES''${MATE_PANEL_EXTRA_MODULES:+:}${config.system.path}/lib/mate-panel/applets

        # Add mate-control-center paths to some XDG variables because its schemas are needed by mate-settings-daemon, and mate-settings-daemon is a dependency for mate-control-center (that is, they are mutually recursive)
        ${addToXDGDirs pkgs.mate.mate-control-center}
        
        export MYVAR3=HIHELLO
      '';
      start = ''
        ${pkgs.mate.mate-session-manager}/bin/mate-session ${optionalString cfg.debug "--debug"}
        #waitPID=$!
      '';
    }];
}    
