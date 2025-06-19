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
        wayland.windowManager.hyprland.settings = {
            exec-once = [
                # Open Telegram on startup in its special workspace
                "[workspace special:telegram silent] Telegram"
            ];

            bindd = [
                # Telegram Special Workspace Bindings
                "SUPER CONTROL SHIFT, T, Move To Special Workspace (Telegram), movetoworkspace, special:telegram"
                "SUPER CONTROL, T, Open Special Workspace (Telegram), togglespecialworkspace, telegram"
            ];

            windowrule = [
                # Always open Telegram in its special workspace
                "workspace special:telegram , class:^(org.telegram.desktop)$"
            ];
        };

        home.packages = [
            pkgs.telegram-desktop
        ];
    };
}