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
        types
        mkIf
        ;
    cfg = config.hmModules.programs.communication.discord;
in
{
    options.hmModules.programs.communication.discord = {
        enable = mkEnableOption "Install and configure a Discord client";
        # arrpc = mkEnableOption "Enable Discord RPC via arrpc";
    };

    config = mkIf cfg.enable {
        # wayland.windowManager.hyprland.settings.bindd = [ "SUPER, D, Open Discord, exec, ${cfg.client}" ];
        home.packages = [
            (pkgs.discord.override {
                withOpenASAR = true;
                withTTS = true;
            }) 
        ];
    };
}