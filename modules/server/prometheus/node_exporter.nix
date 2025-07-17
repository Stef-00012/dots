{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.prometheus-node_exporter;
in
{
    options.modules.server.prometheus-node_exporter = {
        enable = mkEnableOption "Enable prometheus-node_exporter";

        name = mkOption {
            type = types.str;
            default = "Prometheus-node_exporter";
        };

        domain = mkOption {
            type = types.str;
            description = "The domain for prometheus-node_exporter to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for prometheus-node_exporter";
        };

        port = mkOption {
            type = types.port;
            default = 9100;
            description = "The port for prometheus-node_exporter to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        virtualisation.oci-containers.containers."prometheus-node_exporter" = {
            image = "quay.io/prometheus/node-exporter:latest";
            volumes = [
                "/:/host:ro,rslave"
            ];
            cmd = [
                "--path.rootfs=/host"
            ];
            extraOptions = [
                "--network=host"
                "--pid=host"
            ];
        };
    };
}