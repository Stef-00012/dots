{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.kate;
in
{
    options.hmModules.programs.misc.kate = {
        enable = mkEnableOption "Install Kate";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            kdePackages.kate
        ];
    };
}