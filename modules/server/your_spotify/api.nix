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
    cfg = config.modules.server.your_spotify-api;
in
{
    options.modules.server.your_spotify-api = {
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

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for your_spotify API";
        };

        port = mkOption {
            type = types.port;
            default = 9000;
            description = "The port for your_spotify API to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for ";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                enableACME = true;
                forceSSL = true;
                http2 = true;

                serverName = cfg.domain;
                serverAliases = cfg.domainAliases;

                extraConfig = ''
                    client_max_body_size 1024M;
                '';

                locations."/" = {
                    proxyPass = "http://localhost:${toString cfg.port}";
                    extraConfig = ''
                        proxy_set_header Upgrade $http_upgrade;
                        proxy_set_header Connection $http_connection;
                        proxy_http_version 1.1;
                        proxy_set_header Host $host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_set_header X-Forwarded-Proto $scheme;
                    '';
                };
            };
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
                CLIENT_ENDPOINT = "https://${config.modules.server.your_spotify-web.domain}";
                PORT = cfg.port;
                CORS = "i-want-a-security-vulnerability-and-want-to-allow-all-origins";
                API_ENDPOINT = "https://${cfg.domain}";
            };
        };
    };
}