{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.meilisearch;
in
{
    options.modules.server.meilisearch = {
        enable = mkEnableOption "Enable meilisearch";

        name = mkOption {
            type = types.str;
            default = "Meilisearch";
        };

        port = mkOption {
            type = types.port;
            default = 3005;
            description = "The port for meilisearch to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            # default = "meilisearch.stefdp.com";
            description = "The domain for meilisearch to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.meilisearch-env.path = "/var/secrets/meilisearch-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/meilisearch 0755 root root -"
        ];

        virtualisation.oci-containers.containers."meilisearch" = {
            image = "getmeili/meilisearch:v1.12.8";
            ports = [ "${toString cfg.port}:7700" ];
            environmentFiles = [ "/var/secrets/meilisearch-env" ];
            volumes = [
                "/var/lib/meilisearch:/meili_data"
            ];
        };
    };
}