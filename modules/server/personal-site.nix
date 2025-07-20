{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.personal-site;
in
{
    options.modules.server.personal-site = {
        enable = mkEnableOption "Enable personal-site";

        name = mkOption {
            type = types.str;
            default = "Personal Site";
        };

        domain = mkOption {
            type = types.str;
            default = "stefdp.com";
            description = "The domain for personal-site to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for personal-site";
        };

        port = mkOption {
            type = types.port;
            default = 3017;
            description = "The port for personal-site to be hosted at";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/personal-site";
            description = "The Git repository URL for personal-site";
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
        modules.common.sops.secrets.personal-site-env.path = "/var/secrets/personal-site-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/personal-site 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.personal-site = {
            description = "Run personal-site app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.bun
                pkgs.gcc
                pkgs.vips
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/personal-site";
                EnvironmentFile = "/var/secrets/personal-site-env";
                Environment = [
                    "NEXT_TELEMETRY_DISABLED=1"
                    "NODE_ENV=production"
                    "GITHUB_REPO_COUNT=10"
                    "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.vips}/lib"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-personal-site" ''
                    set -e
                    mkdir -p /var/lib/personal-site

                    if [ -z "$(ls -A /var/lib/personal-site)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/personal-site
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-personal-site" ''
                    set -e
                    git add .
                    git stash
                    git pull
                    bun install
                    NEXT_TELEMETRY_DISABLED=1 bun run build
                    NEXT_TELEMETRY_DISABLED=1 bun next start -p ${toString cfg.port}
                '';
                Restart = "on-failure";
            };
        };
    };
}