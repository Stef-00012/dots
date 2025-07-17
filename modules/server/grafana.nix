{
    pkgs,
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
    cfg = config.modules.server.grafana;
in
{
    options.modules.server.grafana = {
        enable = mkEnableOption "Enable grafana";

        name = mkOption {
            type = types.str;
            default = "Grafana";
        };

        domain = mkOption {
            type = types.str;
            default = "grafana.stefdp.com";
            description = "The domain for grafana to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for grafana";
        };

        port = mkOption {
            type = types.port;
            default = 3007;
            description = "The port for grafana to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                # addSSL = true;
                # enableACME = true;
                # forceSSL = true;

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
        services.grafana = {
            enable = true;

            settings.server.http_port = cfg.port;
        };
    };
}