{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.zipline;
in
{
    options.modules.server.zipline = {
        enable = mkEnableOption "Enable zipline";

        name = mkOption {
            type = types.str;
            default = "Zipline";
        };

        port = mkOption {
            type = types.port;
            description = "The port for zipline to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "i.stefdp.com";
            description = "The domain for zipline to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for zipline";
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
        modules.common.sops.secrets.zipline-core-secret.path = "/var/secrets/zipline-core-secret";
        
        systemd.services.zipline.requires = [ "postgresql.service" ];
        systemd.services.zipline.after = [ "postgresql.service" ];

        services.zipline = {
            enable = true;
            environmentFiles = [ config.modules.common.sops.secrets.zipline-core-secret.path ];
            database.createLocally = false;

            settings = {
                CORE_PORT = cfg.port;
                DATABASE_URL = "postgresql://zipline:@localhost/zipline?host=/run/postgresql";
            };
        };
    };
}