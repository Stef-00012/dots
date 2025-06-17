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
        enable = mkEnableOption "Install Kate";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            kdePackages.kate
        ];
    };
}