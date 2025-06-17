{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.widgets.ags;
in
{
    options.hmModules.programs.widgets.ags.enable = {
        enable = mkEnableOption "Enable AGS";
    };

    config = mkIf cfg.enable (
        {
            home.packages = [
                inputs.ags.packages.${pkgs.system}.agsFull
            ]
        }
    );
}