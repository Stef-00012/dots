{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.receiptify;
in
{
    options.modules.server.receiptify = {
        enable = mkEnableOption "Enable receiptify";

        name = mkOption {
            type = types.str;
            default = "Receiptify";
        };

        domain = mkOption {
            type = types.str;
            default = "receiptify.stefdp.com";
            description = "The domain for receiptify to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for receiptify";
        };

        port = mkOption {
            type = types.port;
            default = 3018;
            description = "The port for receiptify to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for receiptify";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for receiptify";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/Stef-00012/receiptify";
            description = "The Git repository URL for receiptify";
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
        modules.common.sops.secrets.receiptify-env.path = "/var/secrets/receiptify-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/receiptify 0755 root root -"
        ];

        environment.systemPackages = with pkgs; [
            git
            bun
        ];

        systemd.services.receiptify = {
            description = "Run receiptify app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.bun
                pkgs.gcc
                pkgs.vips
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/receiptify";
                EnvironmentFile = "/var/secrets/receiptify-env";
                Environment = [
                    "NEXT_TELEMETRY_DISABLED=1"
                    "NODE_ENV=production"
                    "NEXT_PUBLIC_SPOTIFY_REDIRECT_URI=https://${cfg.domain}"
                    "NEXT_PUBLIC_LASTFM_ENABLED=true"
                    "NEXT_PUBLIC_SPOTIFY_ENABLED=true"
                    "NEXT_PUBLIC_UMAMI_URI=https://${config.modules.server.umami.domain}/data.js"
                    "NEXT_PUBLIC_SPOTIFY_CLIENT_ID=e8ed68a2e9414910acec38a6aee777dd"
                    "NEXT_PUBLIC_UMAMI_WEBSITE_ID=702b6c53-da15-4808-801b-17d683e6053d"
                    "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.vips}/lib"
                ];
                ExecStartPre = pkgs.writeShellScript "prepare-receiptify" ''
                    set -e
                    mkdir -p /var/lib/receiptify

                    if [ -z "$(ls -A /var/lib/receiptify)" ]; then
                        git clone ${cfg.repoUrl} /var/lib/receiptify
                    fi
                '';
                ExecStart = pkgs.writeShellScript "run-receiptify" ''
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