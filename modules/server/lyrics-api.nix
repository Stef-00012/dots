{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.lyrics-api;
in
{
    options.modules.server.lyrics-api = {
        enable = mkEnableOption "Enable lyrics-api";

        name = mkOption {
            type = types.str;
            default = "Lyrics API";
        };

        domain = mkOption {
            type = types.str;
            default = "lyrics.stefdp.com";
            description = "The domain for lyrics-api to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 3010;
            description = "The port for lyrics-api to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        virtualisation.oci-containers.containers."lyrics-api" = {
            image = "stefdp/lyrics-api:latest";
            ports = [ "${toString cfg.port}:3000" ];
        };
    };
}