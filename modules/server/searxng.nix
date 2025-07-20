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
    cfg = config.modules.server.searxng;
in
{
    options.modules.server.searxng = {
        enable = mkEnableOption "Enable SearXNG";

        name = mkOption {
            type = types.str;
            default = "SearXNG";
        };

        domain = mkOption {
            type = types.str;
            default = "search.stefdp.com";
            description = "The domain for SearXNG to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for searxng";
        };

        port = mkOption {
            type = types.port;
            default = 3015;
            description = "The port for SearXNG to be hosted at";
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
        modules.common.sops.secrets.searxng-env.path = "/var/secrets/searx-env";

        services.searx = {
            enable = true;
            package = pkgs.searxng;
            environmentFile = "/var/secrets/searx-env";

            settings = {
                general = {
                    contact_url = "mailto:me@stefdp.com";
                };
                search = {
                    safe_search = 1;
                    autocomplete = "google";
                    default_lang = "all";
                };
                server = {
                    base_url = "https://${cfg.domain}/";
                    secret_key = "@SEARX_SECRET_KEY@";
                    port = cfg.port;
                    bind_address = "127.0.0.1";
                    image_proxy = true;
                    default_http_headers = {
                        X-Content-Type-Options = "nosniff";
                        X-XSS-Protection = "1; mode=block";
                        X-Download-Options = "noopen";
                        X-Robots-Tag = "noindex, nofollow";
                        Referrer-Policy = "no-referrer";
                    };
                };
            };
        };
    };
}