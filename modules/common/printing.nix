{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.common.printing;
in
{
    options.modules.common.printing = {
        enable = mkEnableOption "Enable printing";
    };

    config = lib.mkIf cfg.enable {
        services = {
            printing = {
                enable = true;
                drivers = [ pkgs.cnijfilter2 ];
            };

            avahi = {
                enable = true;
                nssmdns4 = true;
                openFirewall = true;
            };
            
            ipp-usb.enable = true;
            samba.enable = true;
        };

        hardware.sane.enable = true; # for scanners
    };
}