{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.cheese;
in
{
    options.hmModules.programs.misc.cheese = {
        enable = mkEnableOption "Install Cheese";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            cheese
        ];
    };
}