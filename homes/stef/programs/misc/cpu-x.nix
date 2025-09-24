{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.cpu-x;
in
{
    options.hmModules.programs.misc.cpu-x = {
        enable = mkEnableOption "Install CPU-X";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            cpu-x
        ];
    };
}