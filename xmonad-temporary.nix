{pkgs, lib, config, ...}:

with lib;
let
  inherit (lib) mkOption mkIf optionals literalExample;
  cfg = config.services.xserver.windowManager.xmonad;
  xmonad = pkgs.xmonad-with-packages.override {
    ghcWithPackages = cfg.haskellPackages.ghcWithPackages;
    packages = self: cfg.extraPackages self ++
                     optionals cfg.enableContribAndExtras
                     [ self.xmonad-contrib self.xmonad-extras ];
  };
  xmonadBin = pkgs.writers.writeHaskell "xmonad" {
    ghc = cfg.haskellPackages.ghc;
    libraries = [ cfg.haskellPackages.xmonad ] ++
                cfg.extraPackages cfg.haskellPackages ++
                optionals cfg.enableContribAndExtras
                (with cfg.haskellPackages; [ xmonad-contrib xmonad-extras ]);
  } cfg.config;

in

{
    config.services.xserver.windowManager.session = mkForce [{
        name = "xmonad";
        start = if (cfg.config != null) then ''
          export XMONADPATH="${xmonadBin}"
          # ${xmonadBin} --replace &
          # waitPID=$!
          # hahaha1
        '' else ''
          # systemd-cat -t xmonad ${xmonad}/bin/xmonad --replace &
          # waitPID=$!
          # hahaha2
        '';
      }];
   
}
