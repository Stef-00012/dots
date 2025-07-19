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
    cfg = config.modules.common.ssh;
in
{
    options.modules.common.ssh = {
        enable = mkEnableOption "Enable fail2ban";
    };

    config = mkIf cfg.enable {
        services.openssh = {
            enable = true;
            openFirewall = true;
            settings = {
                X11Forwarding = true;
                UsePAM = true;
                # PasswordAuthentication = false;
                PasswordAuthentication = true;
                PermitRootLogin = "yes";
                LogLevel = "VERBOSE";
            };
        };
    };
}