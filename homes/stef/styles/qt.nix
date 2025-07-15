{
    config,
    lib,
    pkgs,
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
            platformTheme.name = "qt6ct"; # qt5ct - qtct
            style.name = "Adwaita-dark";
            # style.name = lib.mkForce "adwaita-dark";
            # platformTheme.name = lib.mkForce "gtk3";
        };

        home = {
            packages = with pkgs; [
                libsForQt5.qt5ct
                kdePackages.qt6ct

                adwaita-qt
                adwaita-qt6
            ];
        };
    };
}