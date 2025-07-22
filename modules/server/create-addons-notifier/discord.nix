{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.create-addon-notifier-discord;
in
{
    options.modules.server.create-addon-notifier-discord = {
        enable = mkEnableOption "Enable create-addon-notifier-discord";

        name = mkOption {
            type = types.str;
            default = "Discord Create Addon Notifier Bot";
        };

        # Nothing on this bot uses ports
        port = mkOption {
            type = types.port;
            description = "The port for create-addon-notifier-discord to be hosted at";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/discord-create-notifier";
            description = "The Git repository URL for create-addon-notifier-discord";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.create-addon-notifier-discord-env.path = "/var/secrets/create-addon-notifier-discord-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/create-addon-notifier-discord 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.create-addon-notifier-discord = {
            description = "Run create-addon-notifier-discord app";
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
                WorkingDirectory = "/var/lib/create-addon-notifier-discord";
                EnvironmentFile = "/var/secrets/create-addon-notifier-discord-env";
                Environment = [
                    "CREATE_ADDONS_BASE_URL=create-addons.stefdp.com"
                    "CREATE_ADDONS_SECURE=true"
                    "MODRINTH_EMOJI_ID=1390945361878843402"
                    "CURSEFORGE_EMOJI_ID=1390995939124314132"
                    "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-create-addon-notifier-discord" ''
                    set -e
                    mkdir -p /var/lib/create-addon-notifier-discord

                    if [ -z "$(ls -A /var/lib/create-addon-notifier-discord)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/create-addon-notifier-discord
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-create-addon-notifier-discord" ''
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