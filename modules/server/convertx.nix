{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.convertx;
in
{
    options.modules.server.convertx = {
        enable = mkEnableOption "Enable convertx";

        name = mkOption {
            type = types.str;
            default = "ConvertX";
        };

        domain = mkOption {
            type = types.str;
            default = "convert.stefdp.com";
            description = "The domain for convertx to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for convertx";
        };

        port = mkOption {
            type = types.port;
            default = 3013;
            description = "The port for convertx to be hosted at";
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
        modules.common.sops.secrets.convertx-env.path = "/var/secrets/convertx-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/convertx 0755 root root -"
        ];

        virtualisation.oci-containers.containers."convertx" = {
            image = "ghcr.io/c4illin/convertx";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
            volumes = [
                "/var/lib/convertx:/app/data"
            ];
            environmentFiles = [ "/var/secrets/convertx-env" ];
        };
    };
}