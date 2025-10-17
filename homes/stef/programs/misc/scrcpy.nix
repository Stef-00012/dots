{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.scrcpy;
in
{
    options.hmModules.programs.misc.scrcpy = {
        enable = mkEnableOption "Install SCRCPY";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            scrcpy
        ];
    };
}