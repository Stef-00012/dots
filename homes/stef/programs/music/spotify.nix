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
        wayland.windowManager.hyprland.settings.exec-once = [
            "[workspace special:spotify silent] spotify"
        ];

        home.packages = with pkgs; [
            spotify
        ];
    };
}