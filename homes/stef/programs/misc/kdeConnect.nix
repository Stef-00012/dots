{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.gimp;
in
{
    options.hmModules.programs.misc.gimp = {
        enable = mkEnableOption "Install KDE Connect";
    };

    config = mkIf cfg.enable {
        services.kdeconnect = {
            enable = true;
            indicator = true;
        };
    };
}