{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.syncthing;
in
{
    options.modules.server.syncthing = {
        enable = mkEnableOption "Enable syncthing";

        name = mkOption {
            type = types.str;
            default = "Syncthing";
        };

        domain = mkOption {
            type = types.str;
            default = "syncthing.stefdp.com";
            description = "The domain for syncthing to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 8384;
            description = "The port for syncthing to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        services.syncthing = {
            enable = true;
            overrideFolders = false;
            overrideDevices = false;
        };
    };
}