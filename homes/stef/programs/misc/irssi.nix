{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.irssi;
in
{
    options.hmModules.programs.misc.irssi = {
        enable = mkEnableOption "Install Irssi";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            irssi
        ];
    };
}