{
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.styles.qt;
in
{
    options.hmModules.styles.qt = {
        enable = mkEnableOption "Enable QT styling";
    };
    
    config = mkIf cfg.enable {
        qt = {
            enable = true;
            platformTheme.name = "gtk3";
            style.name = "adwaita-dark";
            # style.name = lib.mkForce "adwaita-dark";
            # platformTheme.name = lib.mkForce "gtk3";
        };
    };
}