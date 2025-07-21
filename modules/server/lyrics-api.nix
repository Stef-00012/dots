{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.lyrics-api;
in
{
    options.modules.server.lyrics-api = {
        enable = mkEnableOption "Enable lyrics-api";

        name = mkOption {
            type = types.str;
            default = "Lyrics API";
        };

        domain = mkOption {
            type = types.str;
            default = "lyrics.stefdp.com";
            description = "The domain for lyrics-api to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for lyrics-api";
        };

        port = mkOption {
            type = types.port;
            default = 3010;
            description = "The port for lyrics-api to be hosted at";
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
        virtualisation.oci-containers.containers."lyrics-api" = {
            image = "stefdp/lyrics-api:latest";
            ports = [ "127.0.0.1:${toString cfg.port}:3000" ];
        };
    };
}