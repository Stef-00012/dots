{ config, pkgs, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.wireguard;
in
{
    options.modules.server.wireguard = {
        enable = mkEnableOption "Enable wireguard";

        name = mkOption {
            type = types.str;
            default = "Wireguard VPN";
        };

        port = mkOption {
            type = types.port;
            default = 51820;
            description = "The port for wireguard to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for wireguard";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for wireguard";
        };

        interface = mkOption {
            type = types.str;
            default = "eth0";
            description = "The name of the wireguard interface";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        networking.nat.enable = true;
        networking.nat.externalInterface = cfg.interface;
        networking.nat.internalInterfaces = [ "wg0" ];
        networking.firewall = {
            allowedUDPPorts = [ 51820 ];
        };

        systemd.tmpfiles.rules = [
            "d /var/lib/wireguard 0755 root root -"
        ];

        networking.wireguard.enable = true;
        networking.wireguard.interfaces = {
            wg0 = {
                ips = [ "10.100.0.1/24" ];
                listenPort = cfg.port;

                postSetup = ''
                    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${cfg.interface} -j MASQUERADE
                '';

                postShutdown = ''
                    ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${cfg.interface} -j MASQUERADE
                '';

                privateKeyFile = "/var/lib/wireguard/privatekey";

                peers = [
                    {
                        publicKey = "t9uJD/IPgkBkrH3ZUXnCVm+6PbaLSxZaJjVoR+2SjCE=";
                        allowedIPs = [ "10.100.0.2/32" ];
                    }
                ];
            };
        };
    };
}