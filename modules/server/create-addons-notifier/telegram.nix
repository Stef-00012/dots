{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.create-addon-notifier-telegram;
in
{
    options.modules.server.create-addon-notifier-telegram = {
        enable = mkEnableOption "Enable create-addon-notifier-telegram";

        name = mkOption {
            type = types.str;
            default = "Telegram Create Addon Notifier Bot";
        };

        # Nothing on this bot uses ports
        port = mkOption {
            type = types.port;
            description = "The port for create-addon-notifier-telegram to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for create-addon-notifier-telegram";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for create-addon-notifier-telegram";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/telegram-create-notifier";
            description = "The Git repository URL for create-addon-notifier-telegram";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.create-addon-notifier-telegram-env.path = "/var/secrets/create-addon-notifier-telegram-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/create-addon-notifier-telegram 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.create-addon-notifier-telegram = {
            description = "Run create-addon-notifier-telegram app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.bun
                pkgs.gcc
                pkgs.vips
                pkgs.openssl_3
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/create-addon-notifier-telegram";
                EnvironmentFile = "/var/secrets/create-addon-notifier-telegram-env";
                Environment = [
                    "CREATE_ADDONS_WEBSOCKET_URI='wss://create-addons.stefdp.com/ws'"
                    "OWNER_IDS=1043573972"
                    "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-create-addon-notifier-telegram" ''
                    set -e
                    mkdir -p /var/lib/create-addon-notifier-telegram

                    if [ -z "$(ls -A /var/lib/create-addon-notifier-telegram)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/create-addon-notifier-telegram
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-create-addon-notifier-telegram" ''
                    set -e
                    git add .
                    git stash
                    git pull
                    bun i
                    bun db:setup
                    bun start
                '';
                Restart = "on-failure";
            };
        };
    };
}