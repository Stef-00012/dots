{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.it-tools;
in
{
    options.modules.server.it-tools = {
        enable = mkEnableOption "Enable it-tools";

        name = mkOption {
            type = types.str;
            default = "IT-Tools";
        };

        domain = mkOption {
            type = types.str;
            default = "tools.stefdp.com";
            description = "The domain for it-tools to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for it-tools";
        };

        port = mkOption {
            type = types.port;
            default = 3014;
            description = "The port for it-tools to be hosted at";
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
        virtualisation.oci-containers.containers."it-tools" = {
            image = "sharevb/it-tools:latest"; # corentinth is the original, sharevb is a guy who forked it-tools
            ports = [ "${toString cfg.port}:8080" ];
        };
    };
}