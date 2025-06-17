{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.gparted;
in
{
    options.hmModules.programs.misc.gparted = {
        enable = mkEnableOption "Install GParted";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            gparted
        ];
    };
}