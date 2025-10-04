{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.programs.qFlipper;
in
{
    options.modules.programs.qFlipper = {
        enable = mkEnableOption "Enable qFlipper";
    };

    config = lib.mkIf cfg.enable {
        # this could be done in hm but i keep it here so i just toggle it in one place
        environment.systemPackages = with pkgs; [
            qFlipper
        ];

        hardware.flipperzero.enable = true;
    };
}