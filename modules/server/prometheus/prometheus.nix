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
            # default = "prometheus.stefdp.com";
            description = "The domain for prometheus to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 9090;
            description = "The port for prometheus to be hosted at";
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
                      - targets: ["173.208.137.167:${toString config.modules.server.prometheus-node_exporter.port}"]
            '';
            webConfigFile = "/var/secrets/prometheus-web.yml";
        };
    };
}