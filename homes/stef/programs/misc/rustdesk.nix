{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.rustdesk;
in
{
    options.hmModules.programs.misc.rustdesk = {
        enable = mkEnableOption "Install Rustdesk";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            rustdesk
        ];
    };
}