{ config, lib, username, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.postgresql;
in
{
    options.modules.server.postgresql = {
        enable = mkEnableOption "Enable PostgreSQL";

        name = mkOption {
            type = types.str;
            default = "PostgreSQL";
        };

        port = mkOption {
            type = types.port;
            default = 5432;
            description = "The port for PostgreSQL to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for ";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        services.postgresql = {
            enable = true;
            settings.port = cfg.port;

            ensureUsers = [
                {
                    name = "zipline";
                    ensureDBOwnership = true;
                }
                {
                    name = "umami";
                    ensureDBOwnership = true;
                }
                {
                    name = "linkwarden";
                    ensureDBOwnership = true;
                }
            ];

            ensureDatabases = [
                "zipline"
                "umami"
                "linkwarden"
            ];

            authentication = builtins.concatStringsSep "\n" (
                map (user: builtins.concatStringsSep "\n" (
                    [
                        "local ${user.name} ${user.name} trust"
                        # "host ${user.name} ${user.name} 127.0.0.1/32 trust"
                        # "host ${user.name} ${user.name} ::1/128 trust"
                    ]
                )) config.services.postgresql.ensureUsers
            );
        };
    };
}