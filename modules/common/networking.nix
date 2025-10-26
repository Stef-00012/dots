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
        # OLD network config, I'll keep it in case the DNS has issues

        # networking = {
        #     networkmanager.enable = true;
        #     hostName = "${host}";
        #     timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
        #     nameservers = lib.singleton "dns.stefdp.com";
        # };

        # # dns things
        # environment.etc = {
        #     "resolv.conf".text = "nameserver 1.1.1.1\n";
        # };

        networking = {
            networkmanager = {
                enable = true;
                dns = "systemd-resolved";
            };
            hostName = "${host}";
            timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
            extraHosts = ''
                107.150.51.36 dns.stefdp.com
            '';
        };

        services.resolved = {
            enable = true;
            fallbackDns = [ ];
            dnssec = "false";
            extraConfig = ''
                DNS=107.150.51.36#dns.stefdp.com
                DNSOverTLS=yes
                Domains=~.
            '';
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