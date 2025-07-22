{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.linkwarden;
in
{
    options.modules.server.linkwarden = {
        enable = mkEnableOption "Enable linkwarden";

        name = mkOption {
            type = types.str;
            default = "Linkwarden";
        };

        port = mkOption {
            type = types.port;
            default = 3004;
            description = "The port for linkwarden to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "links.stefdp.com";
            description = "The domain for linkwarden to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for linkwarden";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for linkwarden";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for linkwarden";
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
        modules.common.sops.secrets.linkwarden-env.path = "/var/secrets/linkwarden-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/linkwarden 0755 root root -"
        ];

        systemd.services.postgresql.before = [ "podman-linkwarden.service" ];
        systemd.services.postgresql.requiredBy = [ "podman-linkwarden.service" ];

        virtualisation.oci-containers.containers.linkwarden = {
            image = "ghcr.io/linkwarden/linkwarden:latest";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
            volumes = [
                "/run/postgresql:/run/postgresql"
                "/var/lib/linkwarden:/data/data"
            ];
            dependsOn = [ "meilisearch" ];
            environmentFiles = [ "/var/secrets/linkwarden-env" ];
            environment = {
                DATABASE_URL = "postgresql://linkwarden:@localhost/linkwarden?host=/run/postgresql";
                NEXTAUTH_URL = "http://localhost:${toString cfg.port}/api/v1/auth";
                MEILI_HOST = "http://localhost:${toString config.modules.server.meilisearch.port}";
                NEXT_PUBLIC_DISABLE_REGISTRATION = "true";
            };
        };
    };
}