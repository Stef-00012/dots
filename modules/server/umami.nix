{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.umami;
in
{
    options.modules.server.umami = {
        enable = mkEnableOption "Enable umami";

        name = mkOption {
            type = types.str;
            default = "Speedtest Tracker";
        };

        port = mkOption {
            type = types.port;
            default = 3011;
            description = "The port for umami to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "umami.stefdp.com";
            description = "The domain for umami to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.umami-app-secret.path = "/var/secrets/umami-app-secret";

        virtualisation.oci-containers.containers.umami = {
            image = "ghcr.io/umami-software/umami:postgresql-latest";
            ports = [ "${toString cfg.port}:3000" ];
            environmentFiles = [ "/var/secrets/umami-app-secret" ];

            volumes = [
                "/run/postgresql:/run/postgresql:ro"
            ];

            environment = {
                DATABASE_URL = "postgresql://umami:@localhost/umami?host=/run/postgresql";
                TRACKER_SCRIPT_NAME = "data.js";
                COLLECT_API_ENDPOINT = "/api/postData";
                DATABASE_TYPE = "postgresql";
            };
        };
    };
}