{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.app-version-control;
in
{
    options.modules.server.app-version-control = {
        enable = mkEnableOption "Enable app-version-control";

        name = mkOption {
            type = types.str;
            default = "App Version Control";
        };

        domain = mkOption {
            type = types.str;
            default = "stefdp.com";
            description = "The domain for app-version-control to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for app-version-control";
        };

        port = mkOption {
            type = types.port;
            default = 3020;
            description = "The port for app-version-control to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for app-version-control";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for app-version-control";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/app-version-control";
            description = "The Git repository URL for app-version-control";
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
        systemd.tmpfiles.rules = [
            "d /var/lib/app-version-control 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.app-version-control = {
            description = "Run app-version-control app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.bun
                pkgs.gcc
                pkgs.vips
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/app-version-control";
                Environment = [
                    "NEXT_TELEMETRY_DISABLED=1"
                    "NODE_ENV=production"
                    "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.vips}/lib"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-app-version-control" ''
                    set -e
                    mkdir -p /var/lib/app-version-control

                    if [ -z "$(ls -A /var/lib/app-version-control)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/app-version-control
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-app-version-control" ''
                    set -e
                    git add .
                    git stash
                    git pull
                    bun install
                    bun db:setup
                    NEXT_TELEMETRY_DISABLED=1 bun run build
                    NEXT_TELEMETRY_DISABLED=1 bun next start -p ${toString cfg.port}
                '';
                Restart = "on-failure";
            };
        };
    };
}