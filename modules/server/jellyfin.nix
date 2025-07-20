{ config, lib, username, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.jellyfin;
in
{
    options.modules.server.jellyfin = {
        enable = mkEnableOption "Enable jellyfin";

        name = mkOption {
            type = types.str;
            default = "Jellyfin";
        };

        port = mkOption {
            type = types.port;
            default = 8096;
            description = "The port for jellyfin to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for jellyfin";
        };

        domain = mkOption {
            type = types.str;
            default = "jellyfin.stefdp.com";
            description = "The domain for jellyfin to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                addSSL = true;
                enableACME = true;
                forceSSL = true;

                serverName = cfg.domain;
                serverAliases = cfg.domainAliases;

                extraConfig = ''
                    client_max_body_size 20M;
                    add_header X-Content-Type-Options "nosniff";
                    add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;
                    add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'; font-src 'self'";
                '';

                locations = {
                    "/" = {
                        proxyPass = "http://localhost:${toString cfg.port}";
                        extraConfig = ''
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                            proxy_set_header X-Forwarded-Proto $scheme;
                            proxy_set_header Host $host;
                            proxy_set_header Upgrade $http_upgrade;
                            proxy_set_header Connection $http_connection;
                            proxy_http_version 1.1;
                            proxy_buffering off;
                        '';
                    };

                    "/socket" = {
                        proxyPass = "http://localhost:${toString cfg.port}";
                        extraConfig = ''
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                            proxy_set_header X-Forwarded-Proto $scheme;
                            proxy_set_header X-Forwarded-Protocol $scheme;
                            proxy_set_header Host $host;
                            proxy_set_header Upgrade $http_upgrade;
                            proxy_set_header Connection $http_connection;
                            proxy_http_version 1.1;
                        '';
                    };
                };
            };
        };
    };

    config = mkIf cfg.enable {
        services.jellyfin = {
            enable = true;
        };
    };
}