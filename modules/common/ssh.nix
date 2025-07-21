{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.common.ssh;
in
{
    options.modules.common.ssh = {
        enable = mkEnableOption "Enable SSH";
    };

    config = mkIf cfg.enable {
        services.openssh = {
            enable = true;

            settings = {
                X11Forwarding = true;
                PermitRootLogin = "no";
                PasswordAuthentication = false;
                LogLevel = "VERBOSE";
            };

            knownHosts = {
                github = {
                    hostNames = [ "github.com" ];
                    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
                };

                server-ed25519 = {
                    hostNames = [ "173.208.137.167" ];
                    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMXeIiWID588k0NIf1VPWrik0nEwhCfzdQWQkxHV9ZG";
                };

                server-rsa = {
                    hostNames = [ "173.208.137.167" ];
                    publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgdEcQaA8mAOgS5JH/U29krN1gOM6/sFV9w2Rx900480V/A294mSw/yY2+k9fpRsccBLGUVKDaqPK5kI8gAyUJ57SC+xdtIyFCNeyMqcY1NtmEk1/suoQ6WGQ4qBMWATEth08848WVQQMXltrVx/bIFoiqFxxyNm4h6eKi2PB0Iw2lbqBPjNtMkstfCx+Nf3jjY+NhtvZLBREyIt7Y2UGddxuEOJ0KrCt9FQ6/RE+wsqYza9C/cGSJ3JPnZw7QmkJ1yHPARaHHvaGpHHh2cJSnfotboI0UV7ifndsPpAtvE6k6wnb8hjIqvprymd3LTHitpsrSMdZxNf0vDnRi3wsHyibUbmzOBR/ZrNzebRtiHvhAkUDCJnpydJ8g2iAaRPhTr8hy2UkoYEbai5atw6hzAVVkocjQtmNDK0PSIOaw+j0zyhx6XZ4rEm4DpHeiZu+/TuHyKdkTdTHKwcjFq46tilQipSYSxhRq+0xRs4J2y0B6zIJmm3YTdZHCdoyRJ3FK2d0CZUlPl6B1mN75xSOSFngoYTicJlBST1PUSPMUhXu96J1U4EhiS5JIyAaOLcmLvYL4RLtIUdWUIjimFKVvbR989mYVG0wX8M9hcu0qVWVM7zDH4KlMsjxAVjQRYq1Zyc6/xH0zSyn+ND1F0Bz45gPrygsoGnyJIAB95jMxtQ==";
                };
            };
        };
    };
}