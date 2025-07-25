{
    pkgs,
    config,
    lib,
    inputs,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.programs.wireguard;
in
{
    options.modules.programs.wireguard = {
        enable = mkEnableOption "Enable wireguard";
        port = lib.mkOption {
            type = lib.types.port;
            default = 51820;
            description = "The port on which the WireGuard server listens";
        };
    };

    config = lib.mkIf cfg.enable {
        networking.firewall = {
            allowedUDPPorts = [ 51820 ];
        };

        systemd.tmpfiles.rules = [
            "d /var/lib/wireguard 0755 root root -"
        ];

        modules.common.sops.secrets.wireguard-private-key-nixos.path = "/var/lib/wireguard/private-key";

        networking.wireguard.enable = true;
        networking.wireguard.interfaces = {
            wg0 = {
                ips = [ "10.100.0.2/24" ];
                listenPort = cfg.port;

                privateKeyFile = "/var/lib/wireguard/private-key";

                peers = [
                    {
                        publicKey = "eyIR7HrP3sF/WyRN4LlLniClgeSMTg0UsIrpMVg+snM=";
                        allowedIPs = [ "0.0.0.0/0" ];
                        endpoint = "173.208.137.167:51820";
                        persistentKeepalive = 25;
                    }
                ];
            };
        };
    };
}