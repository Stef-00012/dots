{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.likeify;
in
{
    options.modules.server.likeify = {
        enable = mkEnableOption "Enable likeify";

        name = mkOption {
            type = types.str;
            default = "Likeify";
        };

        domain = mkOption {
            type = types.str;
            default = "likeify.stefdp.com";
            description = "The domain for likeify to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for likeify";
        };

        port = mkOption {
            type = types.port;
            default = 3008;
            description = "The port for likeify to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                enableACME = true;
                forceSSL = true;

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
        modules.common.sops.secrets.likeify-env.path = "/var/secrets/likeify-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/likeify 0755 root root -"
        ];

        virtualisation.oci-containers.containers."likeify" = {
            image = "stefdp/likeify";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
            environmentFiles = [ "/var/secrets/likeify-env" ];
            volumes = [
                "/var/lib/likeify:/app/data"
            ];
            environment = {
                SPOTIFY_CLIENT_ID="c739c26d591d439bbb439991e5b44315";
                SPOTIFY_BASE_URL="https://likeify.stefdp.com";
                SPOTIFY_DEFAULT_PLAYLIST_NAME="Liked Songs";
                SPOTIFY_DEFAULT_PLAYLIST_DESCRIPTION="Managed by https://github.com/Stef-00012/Likeify";
                REFRESH_INTERVAL="1800000";
            };
        };
    };
}