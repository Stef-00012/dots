{
    config,
    lib,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.vaultwarden;
in
{
    options.modules.server.vaultwarden = {
        enable = mkEnableOption "Enable vaultwarden";

        name = mkOption {
            type = types.str;
            default = "Vaultwarden";
        };

        domain = mkOption {
            type = types.str;
            default = "vw.stefdp.com";
            description = "The domain for vaultwarden to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for vaultwarden";
        };

        port = mkOption {
            type = types.port;
            default = 3006;
            description = "The port for vaultwarden to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for vaultwarden";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for vaultwarden";
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
        modules.common.sops.secrets.vaultwarden-env.path = "/var/lib/vaultwarden.env";

        services.vaultwarden = {
            enable = true;
            backupDir = "/var/backup/vaultwarden";
            environmentFile = "/var/lib/vaultwarden.env";
            config = {
                domain = "https://${cfg.domain}/";
                signupsAllowed = false;
                rocketPort = cfg.port;
                smtpHost = "mail.stefdp.com";
                smtpFrom = "vaultwarden@stefdp.com";
                smtpPort = 587;
                smtpSecurity = "starttls";
                smtpUsername = "vaultwarden@stefdp.com";
            };
        };
    };
}