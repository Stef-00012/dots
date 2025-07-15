{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.apprise-api;
in
{
    options.modules.server.apprise-api = {
        enable = mkEnableOption "Enable apprise-api";

        name = mkOption {
            type = types.str;
            default = "Apprise API";
        };

        domain = mkOption {
            type = types.str;
            # default = "apprise.stefdp.com";
            description = "The domain for apprise-api to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 3012;
            description = "The port for apprise-api to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        systemd.tmpfiles.rules = [
            "d /var/lib/apprise-api 0755 root root -"
            "d /var/lib/apprise-api/config 0755 root root -"
            "d /var/lib/apprise-api/plugin 0755 root root -"
            "d /var/lib/apprise-api/attach 0755 root root -"
        ];

        virtualisation.oci-containers.containers."apprise-api" = {
            image = "caronc/apprise:latest";
            ports = [ "${toString cfg.port}:8000" ];
            volumes = [
                "/var/lib/apprise-api/config:/config"
                "/var/lib/apprise-api/plugin:/plugin"
                "/var/lib/apprise-api/attach:/attach"
            ];
            environment = {
                PUID = "0";
                PGID = "0";
                APPRISE_STATEFUL_MODE = "simple";
                APPRISE_WORKER_COUNT = "1";
                APPRISE_DEFAULT_THEME = "dark";
            };
        };
    };
}