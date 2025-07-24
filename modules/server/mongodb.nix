{
    pkgs,
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
    cfg = config.modules.server.mongodb;
in
{
    options.modules.server.mongodb = {
        enable = mkEnableOption "Enable mongodb";

        name = mkOption {
            type = types.str;
            default = "MongoDB";
        };

        port = mkOption {
            type = types.port;
            default = 27017;
            description = "The port for linkwarden to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for mongodb";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for mongodb";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            mongodb-tools
            mongosh
        ];

        services.mongodb = {
            enable = true;

            extraConfig = ''
                net.port: ${toString cfg.port}
            '';
        };
    };
}