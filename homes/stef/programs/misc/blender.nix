{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.blender;
in
{
    options.hmModules.programs.misc.blender = {
        enable = mkEnableOption "Install Blender";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            blender
        ];
    };
}