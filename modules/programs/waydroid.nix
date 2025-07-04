{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.programs.waydroid;
in
{
    options.modules.programs.waydroid = {
        enable = mkEnableOption "Enable Waydroid";
    };

    config = lib.mkIf cfg.enable {
        virtualisation.waydroid.enable = true;

        environment.systemPackages = with pkgs; [
            wl-clipboard
        ];
    };
}