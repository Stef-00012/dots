{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.weblate;
in
{
    options.modules.server.weblate = {
        enable = mkEnableOption "Enable Weblate";

        name = mkOption {
            type = types.str;
            default = "Weblate";
        };

        domain = mkOption {
            type = types.str;
            default = "translate.stefdp.com";
            description = "The domain for Weblate to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for Weblate";
        };

        port = mkOption {
            type = types.port;
            default = 8080;
            description = "The HTTP port for Weblate to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for Weblate";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            # default = {
            #     http2 = true;

            #     serverName = cfg.domain;
            #     serverAliases = cfg.domainAliases;

            #     extraConfig = ''
            #         client_max_body_size 1024M;
            #     '';

            #     locations = {
            #         "= /favicon.ico".alias = "${finalPackage}/${python.sitePackages}/weblate/static/favicon.ico";
            #         "/static/".alias = "${finalPackage.static}/";
            #         "/media/".alias = "/var/lib/weblate/media/";
            #         "/".proxyPass = "http://unix:///run/weblate.socket";
            #     };
            # };
            default = null;
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.your-spotify-secret.path = "/var/secrets/weblate-smtp-password";

        services.nginx.virtualHosts.${cfg.domain} = {
            http2 = true;
            serverName = cfg.domain;
            serverAliases = cfg.domainAliases;
            extraConfig = ''
                client_max_body_size 1024M;
            '';
            listen = [
                {
                    addr = "0.0.0.0";
                    port = cfg.port;
                    ssl = false;
                }
            ];
        };

        services.weblate = {
            enable = true;
            configurePostgresql = false;
            localDomain = "translate.stefdp.com";
            djangoSecretKeyFile = "/var/secrets/weblate-django-secret-key";

            smtp = {
                enable = false;
                user = "admin@translate.stefdp.com";
                passwordFile = "/var/secrets/weblate-smtp-password";
                host = "mail.stefdp.com";
                port = 587;
            };

            extraConfig = ''
                DATABASES = {
                    "default": {
                        "ENGINE": "django.db.backends.postgresql",
                        "HOST": "/run/postgresql",
                        "NAME": "weblate",
                        "USER": "weblate",
                    }
                }
            '';
        };
    };
}