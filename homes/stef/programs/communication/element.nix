{
    config,
    pkgs,
    lib,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        types
        mkIf
        ;
    cfg = config.hmModules.programs.communication.element;
in
{
    options.hmModules.programs.communication.element = {
        enable = mkEnableOption "Install the Element client";
    };

    config = mkIf cfg.enable {
        home.packages = [
            pkgs.element-desktop
        ];
    };
}