{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.kdeConnect;
in
{
    options.hmModules.programs.misc.kdeConnect = {
        enable = mkEnableOption "Install KDE Connect";
    };

    config = mkIf cfg.enable {
        services.kdeconnect = {
            enable = true;
            indicator = true;
        };
    };
}