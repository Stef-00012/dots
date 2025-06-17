{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.gimp;
in
{
    options.hmModules.programs.misc.gimp = {
        enable = mkEnableOption "Install GIMP";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            gimp3
        ];
    };
}