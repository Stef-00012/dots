{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.realvnc;
in
{
    options.hmModules.programs.misc.realvnc = {
        enable = mkEnableOption "Install realvnc";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            realvnc-vnc-viewer
        ];
    };
}