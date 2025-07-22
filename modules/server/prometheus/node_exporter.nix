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

        port = mkOption {
            type = types.port;
            default = 9100;
            description = "The port for prometheus-node_exporter to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for ";
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