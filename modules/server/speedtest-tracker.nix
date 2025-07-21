{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.speedtest-tracker;
in
{
    options.modules.server.speedtest-tracker = {
        enable = mkEnableOption "Enable speedtest-tracker";

        name = mkOption {
            type = types.str;
            default = "Speedtest Tracker";
        };

        port = mkOption {
            type = types.port;
            default = 6080;
            description = "The port for speedtest-tracker to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "speedtest.stefdp.com";
            description = "The domain for speedtest-tracker to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for speedtest-tracker";
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
        modules.common.sops.secrets.speedtest-tracker-app-key.path = "/var/secrets/speedtest-tracker-app-key";

        systemd.tmpfiles.rules = [
            "d /var/lib/speedtest-tracker 0755 root root -"
        ];

        virtualisation.oci-containers.containers.speedtest-tracker = {
            image = "lscr.io/linuxserver/speedtest-tracker:latest";
            volumes = [ "/var/lib/speedtest-tracker:/config" ];
            ports = [ "127.0.0.1:${toString cfg.port}:80" ];
            environmentFiles = [ "/var/secrets/speedtest-tracker-app-key" ];

            environment = {
                DB_CONNECTION = "sqlite";
                APP_TIMEZONE = config.time.timeZone;
                DISPLAY_TIMEZONE = config.time.timeZone;
                SPEEDTEST_SCHEDULE = "0 */3 * * *";
                APP_URL = "https://${cfg.domain}";
                ASSET_URL = "https://${cfg.domain}";
                PUBLIC_DASHBOARD = "true";
                APP_NAME = "Speedtest";
                PUID = "1000";
                PGID = "1000";
            };
        };
    };
}