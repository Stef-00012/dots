{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.zipline;
in
{
    options.modules.server.zipline = {
        enable = mkEnableOption "Enable zipline";

        name = mkOption {
            type = types.str;
            default = "Zipline";
        };

        port = mkOption {
            type = types.port;
            description = "The port for zipline to be hosted at";
        };

        domain = mkOption {
            type = types.str;
            default = "i.stefdp.com";
            description = "The domain for zipline to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.zipline-core-secret.path = "/var/secrets/zipline-core-secret";
        
        systemd.services.zipline.requires = [ "postgresql.service" ];
        systemd.services.zipline.after = [ "postgresql.service" ];

        services.zipline = {
            enable = true;
            environmentFiles = [ config.modules.common.sops.secrets.zipline-core-secret.path ];
            database.createLocally = false;

            settings = {
                CORE_PORT = cfg.port;
                DATABASE_URL = "postgresql://zipline:@localhost/zipline?host=/run/postgresql";
            };
        };
    };
}