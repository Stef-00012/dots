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

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for zipline";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for zipline";
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

                extraConfig = ''
                    client_max_body_size 4096M;
                '';

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

        systemd.tmpfiles.rules = [
            "d /var/lib/zipline 0755 root root -"
            "d /var/lib/zipline/uploads 0755 root root -"
            "d /var/lib/zipline/public 0755 root root -"
            "d /var/lib/zipline/themes 0755 root root -"
        ];

        systemd.services.postgresql.before = [ "podman-zipline.service" ];
        systemd.services.postgresql.requiredBy = [ "podman-zipline.service" ];

        virtualisation.oci-containers.containers.zipline = {
            image = "ghcr.io/diced/zipline:trunk";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
            environmentFiles = [ "/var/secrets/zipline-core-secret" ];

            volumes = [
                "/run/postgresql:/run/postgresql:ro"
                "/var/lib/zipline/uploads:/zipline/uploads"
                "/var/lib/zipline/public:/zipline/public"
                "/var/lib/zipline/themes:/zipline/themes"
            ];

            environment = {
                DATABASE_URL = "postgresql://zipline:@localhost/zipline?host=/run/postgresql";
            };
        };
    };
}