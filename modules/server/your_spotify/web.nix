{
    config,
    lib,
    pkgs,
    username,
    ...
}:

let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;

    cfg = config.modules.server.your_spotify-web;
in
{
    options.modules.server.your_spotify-web = {
        enable = mkEnableOption "Enable yur_spotify web UI";

        name = mkOption {
            type = types.str;
            default = "your_spotify-web";
        };

        port = mkOption {
            type = types.port;
            default = 3000;
            description = "The port for your_spotify web UI to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "spotify.stefdp.com";
            description = "The domain for your_spotify web UI to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        virtualisation.oci-containers.containers."your_spotify-web" = {
            image = "yooooomi/your_spotify_client";
            ports = [ "${toString cfg.port}:3000" ];
            environment = {
                API_ENDPOINT = "https://${config.modules.server.your_spotify-api.domain}";
            };
        };
    };
}