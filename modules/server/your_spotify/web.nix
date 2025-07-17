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
        enable = mkEnableOption "Enable your_spotify web UI";

        name = mkOption {
            type = types.str;
            default = "your_spotify-web";
        };

        port = mkOption {
            type = types.port;
            default = 3000;
            description = "The port for your_spotify web UI to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for your_spotify web UI";
        };

        domain = mkOption {
            type = types.str;
            default = "spotify.stefdp.com";
            description = "The domain for your_spotify web UI to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                # addSSL = true;
                # enableACME = true;
                # forceSSL = true;

                serverName = cfg.domain;
                serverAliases = cfg.domainAliases;

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
        virtualisation.oci-containers.containers."your_spotify-web" = {
            image = "yooooomi/your_spotify_client";
            ports = [ "${toString cfg.port}:3000" ];
            environment = {
                API_ENDPOINT = "https://${config.modules.server.your_spotify-api.domain}";
            };
        };
    };
}