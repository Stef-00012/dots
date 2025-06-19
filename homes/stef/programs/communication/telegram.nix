{
    config,
    pkgs,
    lib,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        types
        mkIf
        ;
    cfg = config.hmModules.programs.communication.telegram;
in
{
    options.hmModules.programs.communication.telegram = {
        enable = mkEnableOption "Install the Telegram client";
    };

    config = mkIf cfg.enable {
        wayland.windowManager.hyprland.settings.exec-once = [
            "[workspace special:telegram silent] Telegram"
        ];

        home.packages = [
            pkgs.telegram-desktop
        ];
    };
}