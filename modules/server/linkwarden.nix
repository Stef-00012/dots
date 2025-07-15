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
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.linkwarden-env.path = "/var/secrets/linkwarden-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/linkwarden 0755 root root -"
        ];

        virtualisation.oci-containers.containers.linkwarden = {
            image = "ghcr.io/linkwarden/linkwarden:latest";
            ports = [ "${toString cfg.port}:3000" ];
            volumes = [
                "/run/postgresql:/run/postgresql"
                "/var/lib/linkwarden:/data/data"
            ];
            dependsOn = [ "meilisearch" ];
            environmentFiles = [ "/var/secrets/linkwarden-env" ];
            environment = {
                DATABASE_URL = "postgresql://linkwarden:@localhost/linkwarden?host=/run/postgresql";
                NEXTAUTH_URL = "http://localhost:${toString cfg.port}/api/v1/auth";
                MEILI_HOST = "http://localhost:${toString config.modules.server.meilisearch.port}";
                # NEXT_PUBLIC_DISABLE_REGISTRATION = "true";
            };
        };
    };
}