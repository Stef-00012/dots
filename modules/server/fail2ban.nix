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
    cfg = config.modules.server.fail2ban;
in
{
    options.modules.server.fail2ban = {
        enable = mkEnableOption "Enable fail2ban";
    };

    config = mkIf cfg.enable {
        services.fail2ban = {
            enable = true;
            maxretry = 3;
            bantime = "1h";
            ignoreIP = [
                "127.0.0.1"
            ];
        };
    };
}