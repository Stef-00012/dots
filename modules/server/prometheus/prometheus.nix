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
    cfg = config.modules.server.prometheus;
in
{
    options.modules.server.prometheus = {
        enable = mkEnableOption "Enable prometheus";

        name = mkOption {
            type = types.str;
            default = "Prometheus";
        };

        domain = mkOption {
            type = types.str;
            description = "The domain for prometheus to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for prometheus";
        };

        port = mkOption {
            type = types.port;
            default = 9090;
            description = "The port for prometheus to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.prometheus-web-file = {
            path = "/var/secrets/prometheus-web.yml";
            mode = "0666";
        };

        services.prometheus = {
            enable = true;
            port = cfg.port;
            configText = ''
                scrape_configs:
                  - job_name: "prometheus"
                    static_configs:
                      - targets: ["localhost:${toString config.modules.server.prometheus-node_exporter.port}"]
            '';
            webConfigFile = "/var/secrets/prometheus-web.yml";
        };
    };
}