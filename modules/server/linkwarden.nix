{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.linkwarden;
in
{
    options.modules.server.linkwarden = {
        enable = mkEnableOption "Enable linkwarden";

        name = mkOption {
            type = types.str;
            default = "Linkwarden";
        };

        port = mkOption {
            type = types.port;
            default = 3004;
            description = "The port for linkwarden to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "links.stefdp.com";
            description = "The domain for linkwarden to be hosted at";
        };

        meilisearchPort = mkOption {
            type = types.port;
            default = 3005;
            description = "The port for Meilisearch to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.linkwarden-env.path = "/var/secrets/linkwarden-env";

        virtualisation.oci-containers.containers = {
            "linkwarden" = {
                image = "ghcr.io/linkwarden/linkwarden:latest";
                ports = [ "${toString cfg.port}:3000" ];
                volumes = [
                    "/run/postgresql:/run/postgresql"
                ];
                environmentFiles = [ "/var/secrets/linkwarden-env" ];
                environment = {
                    DATABASE_URL = "postgresql://linkwarden:@/linkwarden?host=/run/postgresql";
                    NEXTAUTH_URL = "http://localhost:${toString cfg.port}/api/v1/auth";
                    MEILI_HOST = "http://localhost:${toString cfg.meilisearchPort}";
                    # NEXT_PUBLIC_DISABLE_REGISTRATION = "true";
                };
            };

            "meilisearch" = {
                image = "getmeili/meilisearch:v1.12.8";
                ports = [ "${toString cfg.meilisearchPort}:7700" ];
                environmentFiles = [ "/var/secrets/linkwarden-env" ];
                environment = {
                    DATABASE_URL = "postgresql://linkwarden:@/linkwarden?host=/run/postgresql";
                    # NEXTAUTH_URL = "https://${cfg.domain}/api/v1/auth";
                    NEXTAUTH_URL = "http://localhost:${toString cfg.port}/api/v1/auth";
                };
                volumes = [
                    "/run/postgresql:/run/postgresql"
                    "/var/lib/meilisearch:/meili_data"
                ];
            };
        };
    };
}