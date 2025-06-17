{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.audacity;
in
{
    options.hmModules.programs.misc.audacity = {
        enable = mkEnableOption "Install Audacity";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            audacity
        ];
    };
}