{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.cli.media;
in
{
    options.hmModules.cli.media.enable = mkEnableOption "Enable the media module";

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            imagemagick
            ffmpeg
            yt-dlp
            # tmp fix for catimg build error
            inputs.nixpkgs-cmake-fix.legacyPackages.${pkgs.system}.catimg
        ];
    };
}