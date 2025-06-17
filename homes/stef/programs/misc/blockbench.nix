{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.blockbench;
in
{
    options.hmModules.programs.misc.blockbench = {
        enable = mkEnableOption "Install Blockbench";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            blockbench
        ];
    };
}