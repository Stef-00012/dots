{
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.hypr.idle;
in
{
    options.hmModules.programs.hypr.idle = {
        enable = mkEnableOption "Enable hypridle";
    };

    config = mkIf cfg.enable {
        services.hypridle = {
        enable = true;

        settings = {
            general = {
                after_sleep_cmd = "hyprctl dispatch dpms on";
                ignore_dbus_inhibit = false;
                lock_cmd = "hyprlock";
                unlock_cmd = "pkill -USR1 hyprlock";
            };
            
            listener = [
                {
                    timeout = 10 * 60; # minutes * 60 = seconds
                    on-timeout = "hyprlock";
                }
                {
                    timeout = 60 * 60; # minutes * 60 = seconds
                    on-timeout = "hyprctl dispatch dpms off";
                    on-resume = "hyprctl dispatch dpms on";
                }
            ];
        };
        };
    };
}