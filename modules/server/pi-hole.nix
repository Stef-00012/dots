{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.pi-hole;
in
{
    options.modules.server.pi-hole = {
        enable = mkEnableOption "Enable pi-hole";

        name = mkOption {
            type = types.str;
            default = "PI Hole DNS";
        };

        domain = mkOption {
            type = types.str;
            default = "bot.stefdp.com";
            description = "The domain for pi-hole to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 3007;
            description = "The port for pi-hole to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.pi-hole-env.path = "/var/secrets/pi-hole-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/pi-hole 0755 root root -"
            "d /var/lib/pi-hole/etc 0755 root root -"
            "d /var/lib/pi-hole/dnsmasq.d 0755 root root -"
        ];

        virtualisation.oci-containers.containers."pi-hole" = {
            image = "pihole/pihole:latest";
            ports = [
                "53:53/tcp"
                "53:53/udp"
                "${toString cfg.port}:80/tcp"
            ];
            volumes = [
                "/var/lib/pi-hole/etc:/etc/pihole"
                "/var/lib/pi-hole/dnsmasq.d:/etc/dnsmasq.d"
            ];
            environmentFiles = [ "/var/secrets/pi-hole-env" ];
            environment = {
                TZ = config.time.timeZone;
            };
        };
    };
}