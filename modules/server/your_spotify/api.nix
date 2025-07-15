{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.your_spotify.api;
in
{
    options.modules.server.your_spotify.api = {
        enable = mkEnableOption "Enable your_spotify API";

        name = mkOption {
            type = types.str;
            default = "your_spotify-api";
        };

        domain = mkOption {
            type = types.str;
            default = "api.spotify.stefdp.com";
            description = "The domain for your_spotify API to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 9000;
            description = "The port for your_spotify API to be hosted at";
        };

        clientDomain = mkOption {
            type = types.str;
            default = "spotify.stefdp.com";
            description = "The domain of the your_spotify client";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.your-spotify-secret.path = "/var/secrets/your_spotify-secret";

        services.your_spotify = {
            enable = true;

            spotifySecretFile = "/var/secrets/your_spotify-secret";
            enableLocalDB = true;

            settings = {
                SPOTIFY_PUBLIC = "e5f671a44755418e8fb5a190dbcd9c10";
                CLIENT_ENDPOINT = "https://${cfg.clientDomain}";
                PORT = cfg.port;
                CORS = "i-want-a-security-vulnerability-and-want-to-allow-all-origins";
                API_ENDPOINT = "https://${cfg.domain}";
            };
        };
    };
}