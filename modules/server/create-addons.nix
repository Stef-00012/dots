{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.create-addons;
in
{
    options.modules.server.create-addons = {
        enable = mkEnableOption "Enable create-addons";

        name = mkOption {
            type = types.str;
            default = "Create Addons";
        };

        domain = mkOption {
            type = types.str;
            default = "create-addons.stefdp.com";
            description = "The domain for create-addons to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for create-addons";
        };

        port = mkOption {
            type = types.port;
            default = 3016;
            description = "The port for create-addons to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for create-addons";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for create-addons";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/create-addons";
            description = "The Git repository URL for create-addons";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                enableACME = true;
                forceSSL = true;

                serverName = cfg.domain;
                serverAliases = cfg.domainAliases;

                locations."/" = {
                    proxyPass = "http://localhost:${toString cfg.port}";
                    extraConfig = ''
                        proxy_set_header Upgrade $http_upgrade;
                        proxy_set_header Connection $http_connection;
                        proxy_http_version 1.1;
                        proxy_set_header Host $host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_set_header X-Forwarded-Proto $scheme;
                    '';
                };
            };
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.create-addons-env.path = "/var/secrets/create-addons-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/create-addons 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.create-addons = {
            description = "Run create-addons app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.bun
                pkgs.gcc
                pkgs.vips
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/create-addons";
                EnvironmentFile = "/var/secrets/create-addons-env";
                Environment = [
                    "NEXT_TELEMETRY_DISABLED=1"
                    "NODE_ENV=production"
                    "PORT=${toString cfg.port}"
                    "DB_LOGGING=false"
                    "MODS_PER_PAGE=50"
                    "MODS_FETCH_CRON_INTERVAL='0 */3 * * *'" # every 3 hours
                    "RATELIMIT_REQUEST_AMOUNT=100"
                    "RATELIMIT_REQUEST_INTERVAL=1m" # number + unit format (human readbale format too).
                    "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.vips}/lib"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-create-addons" ''
                    set -e
                    mkdir -p /var/lib/create-addons

                    if [ -z "$(ls -A /var/lib/create-addons)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/create-addons
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-create-addons" ''
                    set -e
                    git add .
                    git stash
                    git pull
                    bun install
                    bun db:setup
                    bun run build
                    exec bun run src/server.ts
                '';
                Restart = "on-failure";
            };
        };
    };
}