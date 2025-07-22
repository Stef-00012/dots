{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.discord-user-apps;
in
{
    options.modules.server.discord-user-apps = {
        enable = mkEnableOption "Enable discord-user-apps";

        name = mkOption {
            type = types.str;
            default = "Discord User Apps Bot";
        };

        domain = mkOption {
            type = types.str;
            default = "bot.stefdp.com";
            description = "The domain for discord-user-apps to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for discord-user-apps";
        };

        port = mkOption {
            type = types.port;
            default = 3009;
            description = "The port for discord-user-apps to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for discord-user-apps";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for discord-user-apps";
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
        modules.common.sops.secrets.discord-user-apps-env.path = "/var/secrets/discord-user-apps-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/discord-user-apps 0755 root root -"
            "d /var/lib/discord-user-apps/data 0755 root root -"
            "d /var/lib/discord-user-apps/permissions 0755 root root -"
            "d /var/lib/discord-user-apps/migrations 0755 root root -"
        ];

        virtualisation.oci-containers.containers."discord-user-apps" = {
            image = "stefdp/discord-user-apps";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
            volumes = [
                "/var/lib/discord-user-apps/data:/bot/data"
                "/var/lib/discord-user-apps/permissions:/bot/src/data/permissions"
                "/var/lib/discord-user-apps/migrations:/bot/drizzle"
            ];
            environmentFiles = [ "/var/secrets/discord-user-apps-env" ];
            environment = {
                APPRISE_URL = "http://localhost:${toString config.modules.server.apprise-api.port}";
                OWNERS = "694986201739952229";
                PUBLIC = "true";
                AUTO_UPDATE_AVATAR = "694986201739952229";
                ZIPLINE_URL = "https://i.stefdp.com";
                ZIPLINE_CHUNK_SIZE = "20";
                ZIPLINE_MAX_FILE_SIZE = "1024";
                ZIPLINE_VERSION = "v4";
                DASHBOARD_ENABLED = "true";
                DASHBOARD_HOSTNAME = "bot.stefdp.com";
                DASHBOARD_SECURE = "true";
                DASHBOARD_URL_KEEP_PORT = "false";
                DISCORD_CLIENT_ID = "1223221223685886032";
                DISCORD_REDIRECT_URI = "http://bot.stefdp.com/login";
                DISCORD_WEBHOOK_ENABLED= "true";
            };
            dependsOn = [
                "apprise-api"
            ];
        };
    };
}