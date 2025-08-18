{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.godot;
in
{
    options.hmModules.programs.misc.godot = {
        enable = mkEnableOption "Install Godot";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            godot
        ];
    };
}