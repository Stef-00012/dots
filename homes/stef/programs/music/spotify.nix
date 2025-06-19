{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.music.spotify;
in
{
    options.hmModules.programs.music.spotify = {
        enable = mkEnableOption "Install the Spotify Client (do not enable if spicetify is enabled)";
    };

    config = mkIf cfg.enable {
        wayland.windowManager.hyprland.settings = {
            exec-once = [
                # Open Spotify on startup in its special workspace
                "[workspace special:spotify silent] spotify"
            ];

            bindd = [
                # Spotify Special Workspace Bindings
                "SUPER CONTROL SHIFT, S, Move To Special Workspace (Spotify), movetoworkspace, special:spotify"
                "SUPER CONTROL, S, Open Special Workspace (Spotify), togglespecialworkspace, spotify"
            ];

            windowrule = [
                # Always open Spotify in its special workspace
                "workspace special:spotify , class:^(spotify)$"
            ];
        };

        home.packages = with pkgs; [
            spotify
        ];
    };
}