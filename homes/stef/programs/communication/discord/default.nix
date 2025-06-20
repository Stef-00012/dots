{
    config,
    pkgs,
    lib,
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
            wayland.windowManager.hyprland.settings = {
                exec-once = mkIf cfg.arrpc [
                    # "sleep 3; ${pkgs.arrpc}/bin/arrpc &"
                    "${pkgs.arrpc}/bin/arrpc &"
                ];

                bindd = [
                    # Discord Special Workspace Bindings
                    "SUPER CONTROL SHIFT, D, Move To Special Workspace (Discord), movetoworkspace, special:discord"
                    "SUPER CONTROL, D, Open Special Workspace (Discord), togglespecialworkspace, discord"
                ];
            };

            home.packages = [
                (pkgs.discord.override {
                    withOpenASAR = true;
                    withTTS = true;
                }) 
            ];
        })

        (mkIf (cfg.enable && !chromiumCfg.enable) {
            wayland.windowManager.hyprland.settings = {
                # Discord App Special Workspace Bindings
                bindd = [ "SUPER, D, Open Discord, exec, discord" ];

                exec-once = [
                    # Open Discord App on startup in its special workspace
                    "[workspace special:discord silent] discord"
                ];

                windowrule = [
                    # Always open Discord App in its special workspace
                    "workspace special:discord , class:^(discord)$"
                ];
            };
        })

        (mkIf (cfg.enable && chromiumCfg.enable) {
            wayland.windowManager.hyprland.settings = {
                # Discord Web App Special Workspace Bindings
                bindd = [ "SUPER, D, Open Discord, exec, bash ${./script.sh}" ];

                exec-once = [
                    # Open Discord Web App on startup in its special workspace
                    "[workspace special:discord silent] bash ${./script.sh}"
                ];

                windowrule = [
                    # Always open Discord Web App in its special workspace
                    "workspace special:discord , class:^(chrome-discord.com__app-Default)$"
                ];
            };
        })
    ];
}