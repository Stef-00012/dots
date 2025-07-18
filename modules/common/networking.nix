{
    pkgs,
    config,
    host,
    lib,
    options,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.common.networking;
in
{
    options.modules.common.networking = {
        enable = mkEnableOption "Enable networking";
    };

    config = lib.mkIf cfg.enable {
        networking = {
            networkmanager.enable = true;
            hostName = "${host}";
            timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
        };
        # dns things
        environment.etc = {
            "resolv.conf".text = "nameserver 1.1.1.1\n";
        };
        networking.firewall = {
            enable = true;

            allowedTCPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ]; # KDE Connect
            allowedUDPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ]; # KDE Connect
        };

        environment.systemPackages = with pkgs; [
            traceroute
            speedtest-cli
            networkmanagerapplet
            ncftp
            dig
            wget
            xh
        ];
    };
}