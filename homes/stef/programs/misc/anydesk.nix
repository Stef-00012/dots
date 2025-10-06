{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.anydesk;
in
{
    options.hmModules.programs.misc.anydesk = {
        enable = mkEnableOption "Install Anydesk";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            anydesk
        ];
    };
}