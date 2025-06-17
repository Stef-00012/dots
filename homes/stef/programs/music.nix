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
        enable = mkEnableOption "Install the Spotify Client";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            spotify
        ];
    };
}