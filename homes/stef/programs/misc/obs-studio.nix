{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.obs-studio;
in
{
    options.hmModules.programs.misc.obs-studio = {
        enable = mkEnableOption "Install OBS Studio";
    };

    config = mkIf cfg.enable {
        programs.obs-studio = {
            enable = true;
        };
    };
}