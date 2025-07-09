{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.hypr.lock;
in
{
    options.hmModules.programs.hypr.lock = {
        enable = mkEnableOption "Enable hyprlock";
    };
    
    config = mkIf cfg.enable {
        home.packages = [ pkgs.hyprlock ];

        wayland.windowManager.hyprland.settings.bindd = [
            "SUPER, L, Lock Screen, exec, hyprlock"
        ];
    };
}