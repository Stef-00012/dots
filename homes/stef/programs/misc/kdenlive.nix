{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.kdenlive;
in
{
    options.hmModules.programs.misc.kdenlive = {
        enable = mkEnableOption "Install Kdenlive";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            kdePackages.kdenlive
        ];
    };
}