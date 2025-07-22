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
        modules.common.sops.secrets.meilisearch-env.path = "/var/secrets/meilisearch-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/meilisearch 0755 root root -"
        ];

        virtualisation.oci-containers.containers."meilisearch" = {
            image = "getmeili/meilisearch:v1.12.8";
            ports = [ "127.0.0.1:${toString cfg.port}:7700" ];
            environmentFiles = [ "/var/secrets/meilisearch-env" ];
            volumes = [
                "/var/lib/meilisearch:/meili_data"
            ];
        };
    };
}