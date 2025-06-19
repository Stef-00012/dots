{
    config,
    pkgs,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        mkMerge
        types
        mkIf
        ;
    cfg = config.hmModules.programs.communication.discord;
    chromiumCfg = config.hmModules.programs.browsers.chromium;
in
{
    options.hmModules.programs.communication.discord = {
        enable = mkEnableOption "Install and configure a Discord client";
        arrpc = mkEnableOption "Enable Discord RPC via arrpc";
    };

    config = mkMerge [
        (mkIf cfg.enable {
            wayland.windowManager.hyprland.settings.exec-once = mkIf cfg.arrpc.enable [
                "sleep 3; ${pkgs.arrpc}/bin/arrpc &"
            ];

            home.packages = [
                (pkgs.discord.override {
                    withOpenASAR = true;
                    withTTS = true;
                }) 
            ];
        })

        (mkIf (cfg.enable && !chromiumCfg.enable) {
            wayland.windowManager.hyprland.settings.bindd = [ "SUPER, D, Open Discord, exec, discord" ];
        })

        (mkIf (cfg.enable && chromiumCfg.enable) {
            wayland.windowManager.hyprland.settings.bindd = [ "SUPER, D, Open Discord, exec, bash ${./script.sh}" ];
        })
    ];
}