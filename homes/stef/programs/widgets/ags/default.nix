{
    config,
    lib,
    pkgs,
    inputs,
    username,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.widgets.ags;
in
{
    imports = [ inputs.ags.homeManagerModules.default ];

    options.hmModules.programs.widgets.ags = {
        enable = mkEnableOption "Enable AGS";
    };

    config = mkIf cfg.enable (
        {
            programs.ags = {
                enable = true;

                configDir = ./config;

                extraPackages = with pkgs; [
                    inputs.astal.packages.${pkgs.system}.io
                    inputs.astal.packages.${pkgs.system}.astal4
                    inputs.astal.packages.${pkgs.system}.apps
                    inputs.astal.packages.${pkgs.system}.auth
                    inputs.astal.packages.${pkgs.system}.battery
                    inputs.astal.packages.${pkgs.system}.bluetooth
                    # inputs.astal.packages.${pkgs.system}.cava
                    inputs.astal.packages.${pkgs.system}.hyprland
                    inputs.astal.packages.${pkgs.system}.mpris
                    inputs.astal.packages.${pkgs.system}.network
                    inputs.astal.packages.${pkgs.system}.notifd
                    inputs.astal.packages.${pkgs.system}.powerprofiles
                    inputs.astal.packages.${pkgs.system}.tray
                    inputs.astal.packages.${pkgs.system}.wireplumber
                    libsoup_3
                    glib-networking
                    libadwaita
                ];
            };

            home.packages = [
                inputs.astal.packages.${pkgs.system}.io
                inputs.astal.packages.${pkgs.system}.apps
                inputs.astal.packages.${pkgs.system}.auth
                inputs.astal.packages.${pkgs.system}.battery
                inputs.astal.packages.${pkgs.system}.hyprland
                inputs.astal.packages.${pkgs.system}.mpris
                inputs.astal.packages.${pkgs.system}.notifd
                inputs.astal.packages.${pkgs.system}.powerprofiles #
                inputs.astal.packages.${pkgs.system}.tray
            ];

            wayland.windowManager.hyprland.settings = {
                bindd = [
                    # Notifications
                    "SUPER, N, Open Notification Center, exec, ags request -i desktop-shell toggle-notif"
                    "SUPER SHIFT, N, Clear Notifications, exec, ags request -i desktop-shell clear-notif"

                    # Launchers
                    "SUPER, SPACE, Open Launcher, exec, ags request -i desktop-shell toggle-launcher-app"
                    "SUPER ALT, C, Open Calculator, exec, ags request -i desktop-shell toggle-launcher-calculator"

                    # Clipboard (home/stef/misc/clipboard.nix)
                    ## "SUPER, V, Open Clipboard, exec, ags request -i desktop-shell toggle-launcher-clipboard"

                    # Session Menu
                    "SUPER, BACKSLASH, Open Session Menu, exec, ags request -i desktop-shell toggle-session-menu"
                ];

                windowrule = [
                    "float, class:^(gjs)$"
                    "noanim, class:^(gjs)$"

                    "noblur, class:^(gjs)$, title:negative:^(AGS Session Menu)$"
                    "pin, class:^(gjs)$, title:^(AGS Session Menu)$"

                    "pin, class:^(gjs)$, title:^(AGS Notification Center)$"
                ];

                layerrule = [
                    "noanim, gtk4-layer-shell"
                ];

                exec-once = [
                    "ags run"
                ];
            };
        }
    );
}