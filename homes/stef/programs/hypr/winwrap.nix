{
    pkgs,
    config,
    lib,
    inputs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.hypr.winwrap;
in
{
    options.hmModules.programs.hypr.winwrap = {
        enable = mkEnableOption "Enable winwrap plugin";
    };
    
    config = mkIf cfg.enable {
        wayland.windowManager.hyprland = {
            plugins = [
                inputs.hyprland-plugins.packages.${pkgs.system}.hyprwinwrap
            ];

            settings = {
                plugin = {
                    hyprwinwrap = {
                        class = "kitty-bg";
                    };
                };

                exec-once = [
                    "kitty --class 'kitty-bg' --hold sh -c 'sleep 1 && cava'"
                ];
            };
        };

        home.packages = [
            pkgs.cava
        ];
    };
}