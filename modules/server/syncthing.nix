{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.syncthing;
in
{
    options.modules.server.syncthing = {
        enable = mkEnableOption "Enable syncthing";

        name = mkOption {
            type = types.str;
            default = "Syncthing";
        };

        domain = mkOption {
            type = types.str;
            default = "syncthing.stefdp.com";
            description = "The domain for syncthing to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for syncthing";
        };

        port = mkOption {
            type = types.port;
            default = 8384;
            description = "The port for syncthing to be hosted at";
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
                        # proxy_set_header Host $host;
                        proxy_set_header Host localhost;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_set_header X-Forwarded-Proto $scheme;
                    '';
                };
            };
        };
    };

    config = mkIf cfg.enable {
        services.syncthing = {
            enable = true;
            overrideFolders = false;
            overrideDevices = false;
        };

        networking.firewall.allowedTCPPorts = [ 8384 ];
    };
}