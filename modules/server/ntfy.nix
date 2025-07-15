{
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
    cfg = config.modules.server.ntfy;
in
{
    options.modules.server.ntfy = {
        enable = mkEnableOption "Enable ntfy";

        name = mkOption {
            type = types.str;
            default = "Ntfy";
        };

        domain = mkOption {
            type = types.str;
            default = "ntfy.stefdp.com";
            description = "The domain for ntfy to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 3003;
            description = "The port for ntfy to be hosted at";
        };

        dataDir = mkOption {
            type = types.str;
            default = "/var/lib/ntfy";
            description = "Path to the data dir";
        };
    };

    config = mkIf cfg.enable {
        # systemd.tmpfiles.rules = [
        #     "d ${cfg.dataDir} 0755 ntfy-sh ntfy-sh -"
        #     "d ${cfg.dataDir}/attachments 0755 ntfy-sh ntfy-sh -"
        # ];

        # systemd.services.ntfy-sh.serviceConfig.StateDirectory = lib.mkForce "ntfy";

        services.ntfy-sh = {
            enable = true;

            settings = {
                base-url = "https://${cfg.domain}";
                listen-http = ":${toString cfg.port}";

                # cache-file = "${cfg.dataDir}/cache.db";
                # auth-file = "${cfg.dataDir}/auth.db";

                auth-default-access = "deny-all";
                behind-proxy = true;

                # attachment-cache-dir = "${cfg.dataDir}/attachments";
                attachment-total-size-limit = "3G";

                # web-push-public-key = "REDACTED";
                # web-push-private-key = "REDACTED";
                # web-push-file = ${cfg.dataDir}/webpush.db;
                # web-push-email-address = "me@stefdp.com";

                enable-login = true;

                upstream-base-url = "https://ntfy.sh";

                enable-metrics = false;

                log-level = "info";
                log-level-overrides = [
                    "tag=manager -> trace"
                    "emails_received -> trace"
                    "emails_received_failure -> trace"
                    "emails_received_success -> trace"
                    "emails_sent -> trace"
                    "emails_sent_failure -> trace"
                    "emails_sent_success -> trace"
                ];
            };
        };
    };
}