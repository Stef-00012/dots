{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.misc.emote;
in
{
    options.hmModules.misc.emote.enable = mkEnableOption "Enable the Emote Picker";

    config = mkIf cfg.enable {
        home.packages = with pkgs; [ emote ];

        wayland.windowManager.hyprland.settings = {
            bindd = [
                "SUPER, PERIOD, Open Clipboard, exec, emote"
            ];
        };
    };
}