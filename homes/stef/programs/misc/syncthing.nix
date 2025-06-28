{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.syncthing;
in
{
    options.hmModules.programs.misc.syncthing = {
        enable = mkEnableOption "Enable Syncthing";
    };

    config = mkIf cfg.enable {
        services.syncthing = {
            enable = true;
            overrideFolders = false;
            overrideDevices = false;

            tray = {
                enable = true;
            };
        };
    };
}