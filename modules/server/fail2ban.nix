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

        name = mkOption {
            type = types.str;
            default = "Fail2ban";
        };

        domain = mkOption {
            type = types.str;
            description = "The domain for fail2ban to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for fail2ban";
        };

        port = mkOption {
            type = types.port;
            description = "The port for fail2ban to be hosted at";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = null;
        };
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