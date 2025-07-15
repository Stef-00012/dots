{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.likeify;
in
{
    options.modules.server.likeify = {
        enable = mkEnableOption "Enable likeify";

        name = mkOption {
            type = types.str;
            default = "Likeify";
        };

        domain = mkOption {
            type = types.str;
            default = "likeify.stefdp.com";
            description = "The domain for likeify to be hosted at";
        };

        port = mkOption {
            type = types.port;
            default = 3008;
            description = "The port for likeify to be hosted at";
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.likeify-env.path = "/var/secrets/likeify-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/likeify 0755 root root -"
        ];

        virtualisation.oci-containers.containers."likeify" = {
            image = "stefdp/likeify";
            ports = [ "${toString cfg.port}:3000" ];
            environmentFiles = [ "/var/secrets/likeify-env" ];
            volumes = [
                "/var/lib/likeify:/app/data"
            ];
            environment = {
                SPOTIFY_CLIENT_ID="c739c26d591d439bbb439991e5b44315";
                SPOTIFY_BASE_URL="https://likeify.stefdp.com";
                SPOTIFY_DEFAULT_PLAYLIST_NAME="Liked Songs";
                SPOTIFY_DEFAULT_PLAYLIST_DESCRIPTION="Managed by https://github.com/Stef-00012/Likeify";
                REFRESH_INTERVAL="1800000";
            };
        };
    };
}