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

        port = mkOption {
            type = types.port;
            default = 3007;
            description = "The port for grafana to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        services.grafana = {
            enable = true;

            settings.server.http_port = cfg.port;
        };
    };
}