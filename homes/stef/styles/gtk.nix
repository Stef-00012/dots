{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.styles.gtk;
in
{
    options.hmModules.styles.gtk = {
        enable = mkEnableOption "Enable GTK theming";
    };
    
    config = mkIf cfg.enable {
        gtk = {
            enable = true;

            theme = {
                package = pkgs.gnome-themes-extra;
                name = "Adwaita-dark";
            };

            iconTheme = {
                package = pkgs.adwaita-icon-theme;
                name = "Adwaita";
            };

            gtk3.extraConfig = {
                gtk-application-prefer-dark-theme = 1;
            };

            gtk4.extraConfig = {
                gtk-application-prefer-dark-theme = 1;
            };

            font = {
                name = "Sans";
                size = 11;
            };
        };
        
        xresources.properties = {
            "Xcursor.size" = 20;
        };
    };
}