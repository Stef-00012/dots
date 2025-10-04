{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.libreoffice;
in
{
    options.hmModules.programs.misc.libreoffice = {
        enable = mkEnableOption "Install Libreoffice";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            libreoffice-qt6-fresh
        ];
    };
}