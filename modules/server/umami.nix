{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.umami;
in
{
    options.modules.server.umami = {
        enable = mkEnableOption "Enable umami";

        name = mkOption {
            type = types.str;
            default = "Speedtest Tracker";
        };

        port = mkOption {
            type = types.port;
            default = 3011;
            description = "The port for umami to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "umami.stefdp.com";
            description = "The domain for umami to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for umami";
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
        modules.common.sops.secrets.umami-app-secret.path = "/var/secrets/umami-app-secret";

        systemd.services.postgresql.before = [ "podman-umami.service" ];
        systemd.services.postgresql.requiredBy = [ "podman-umami.service" ];

        virtualisation.oci-containers.containers.umami = {
            image = "ghcr.io/umami-software/umami:postgresql-latest";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
            environmentFiles = [ "/var/secrets/umami-app-secret" ];

            volumes = [
                "/run/postgresql:/run/postgresql:ro"
            ];

            environment = {
                DATABASE_URL = "postgresql://umami:@localhost/umami?host=/run/postgresql";
                TRACKER_SCRIPT_NAME = "data.js";
                COLLECT_API_ENDPOINT = "/api/postData";
                DATABASE_TYPE = "postgresql";
            };
        };
    };
}