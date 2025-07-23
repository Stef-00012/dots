{
    config,
    lib,
    pkgs,
    username,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.cli.compression;
in
{
    options.hmModules.cli.rclone = {
        enable = mkEnableOption "Enable rclone CLI";
    };

    config = mkIf cfg.enable {
        programs.rclone = {
            enable = true;
            
            remotes.gdrive = {
                config = {
                    type = "drive";
                    scope = "drive";
                };

                secrets = {
                    client_id = "/var/secrets/gdrive-client-id";
                    client_secret = "/var/secrets/gdrive-client-secret";
                    token = "/var/secrets/gdrive-token";
                };
            };
        };
    };
}