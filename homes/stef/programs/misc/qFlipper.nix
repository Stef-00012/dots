{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.qFlipper;
in
{
    options.hmModules.programs.misc.qFlipper = {
        enable = mkEnableOption "Install QFlipper";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            qFlipper
        ];
    };
}