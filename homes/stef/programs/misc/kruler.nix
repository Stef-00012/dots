{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.kruler;
in
{
    options.hmModules.programs.misc.kruler = {
        enable = mkEnableOption "Install KRuler";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            kdePackages.kruler
        ];

        wayland.windowManager.hyprland.settings.windowrule = [
            # Open KRuler as popup
            "float, class:^(org.kde.kruler)$"
        ];
    };
}