{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.api;
in
{
    options.modules.server.api = {
        enable = mkEnableOption "Enable api";

        name = mkOption {
            type = types.str;
            default = "API";
        };

        domain = mkOption {
            type = types.str;
            default = "api.stefdp.com";
            description = "The domain for api to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for api";
        };

        # Nothing on this bot uses ports
        port = mkOption {
            type = types.port;
            default = 3019;
            description = "The port for api to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for api";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for api";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/api";
            description = "The Git repository URL for api";
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
        modules.common.sops.secrets.api-env.path = "/var/secrets/api-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/api 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.api = {
            description = "Run api app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.bun
                pkgs.gcc
                pkgs.vips
                pkgs.openssl_3
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/api";
                EnvironmentFile = "/var/secrets/api-env";
                Environment = [
                    "PORT=${toString cfg.port}"
                    "YOUR_SPOTIFY_API_URL=https://${config.modules.server.your_spotify-api.domain}"
                    "SPOTIFY_JOIN_DATE=2020-04-17T09:53:57.348Z"
                    "SPOTIFY_UPDATE_INTERVAL=60000"
                    "SPOTIFY_DEFAULT_NO_DATA_MESSAGE=Loading..."
                    "TZ=${config.time.timeZone}"
                    "NTFY_URL=https://${config.modules.server.ntfy.domain}"
                    "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-api" ''
                    set -e
                    mkdir -p /var/lib/api

                    if [ -z "$(ls -A /var/lib/api)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/api
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-api" ''
                    set -e
                    git add .
                    git stash
                    git pull
                    bun i
                    bun start
                '';
                Restart = "on-failure";
            };
        };
    };
}