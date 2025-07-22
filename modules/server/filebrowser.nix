{
    config,
    lib,
    pkgs,
    username,
    ...
}:

let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;

    cfg = config.modules.server.filebrowser;

    dataDirGenerated = pkgs.runCommand "filebrowser-data" { } ''
        mkdir -p $out
        mkdir -p $out/data
        echo '${lib.generators.toYAML { } cfg.settings}' > $out/data/config.yaml
    '';
in
{
    options.modules.server.filebrowser = {
        enable = mkEnableOption "Enable Filebrowser";

        name = mkOption {
            type = types.str;
            default = "FileBrowser Quantum";
        };

        port = mkOption {
            type = types.port;
            default = 5080;
            description = "The port for Filebrowser to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "fb.stefdp.com";
            description = "The domain for Filebrowser to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for Filebrowser";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for filebrowser";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for filebrowser";
        };

        dataDir = mkOption {
            type = types.str;
            default = "/var/lib/filebrowser";
            description = "Host path to the folder you want to expose inside Filebrowser as /folder";
        };

        settings = mkOption {
            type = types.attrs;
            description = "Filebrowser configuration. See https://github.com/gtsteffaniak/filebrowser/wiki/Configuration-And-Examples for documentation";
            default = {
                server = {
                    sources = [ { path = "/files"; } ];
                    port = cfg.port;
                    baseURL = "/";
                };

                frontend = {
                    name = "files";
                    disableDefaultLinks = true;
                };

                auth.adminUsername = username;
                integrations.media.ffmpegPath = "${pkgs.ffmpeg}/bin";
            };
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
        modules.common.sops.secrets.filebrowser-env.path = "/var/secrets/filebrowser-env"; # format: FILEBROWSER_ADMIN_PASSWORD=123

        systemd.tmpfiles.rules = [
            "d ${cfg.dataDir} 0755 root root -"
        ];

        virtualisation.oci-containers.containers."filebrowser" = {
            image = "gtstef/filebrowser";
            ports = [ "127.0.0.1:${toString cfg.port}:${toString cfg.port}" ];
            environment = {
                FILEBROWSER_CONFIG = "data/config.yaml";
                TZ = config.time.timeZone;
            };
            environmentFiles = [ config.modules.common.sops.secrets.filebrowser-env.path ];
            volumes = [
                "${cfg.dataDir}:/data"
                "${dataDirGenerated}/data:/home/filebrowser/data"
                "/home/${username}:/files"
            ];
        };
    };
}