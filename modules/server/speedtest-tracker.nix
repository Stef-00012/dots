{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.speedtest-tracker;
in
{
    options.modules.server.speedtest-tracker = {
        enable = mkEnableOption "Enable speedtest-tracker";

        name = mkOption {
            type = types.str;
            default = "Speedtest Tracker";
        };

        port = mkOption {
            type = types.port;
            default = 6080;
            description = "The port for speedtest-tracker to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "speedtest.stefdp.com";
            description = "The domain for speedtest-tracker to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.speedtest-tracker-app-key.path = "/var/secrets/speedtest-tracker-app-key";

        systemd.tmpfiles.rules = [
            "d /var/lib/speedtest-tracker 0755 root root -"
        ];

        virtualisation.oci-containers.containers.speedtest-tracker = {
            image = "lscr.io/linuxserver/speedtest-tracker:latest";
            volumes = [ "/var/lib/speedtest-tracker:/config" ];
            ports = [ "${toString cfg.port}:80" ];
            environmentFiles = [ "/var/secrets/speedtest-tracker-app-key" ];

            environment = {
                DB_CONNECTION = "sqlite";
                APP_TIMEZONE = config.time.timeZone;
                DISPLAY_TIMEZONE = config.time.timeZone;
                SPEEDTEST_SCHEDULE = "0 */3 * * *";
                APP_URL = "https://${cfg.domain}";
                ASSET_URL = "https://${cfg.domain}";
                PUBLIC_DASHBOARD = "true";
                APP_NAME = "Speedtest";
                PUID = "1000";
                PGID = "1000";
                CHART_DATETIME_FORMAT = "m/j G.i";
                DATETIME_FORMAT = "j M Y, G.i.s";
                SPEEDTEST_SERVERS = "26065,24115";
            };
        };
    };
}