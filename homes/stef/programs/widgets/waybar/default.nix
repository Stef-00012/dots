# ===========================================================================
# =========== THIS FILE IS TEMPORARY UNTIL I MAKE MY BAR WITH AGS ===========
# ===========================================================================

{
    pkgs,
    config,
    username,
    lib,
    host,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.widgets.waybar;
    waybarBottom = false; # If the waybar should be at the bottom of the screen instead of the top
in
{
    imports = [ ./style.nix ];
    options.hmModules.programs.widgets.waybar = {
        enable = mkEnableOption "Enable waybar";
    };
    config = mkIf cfg.enable {
        home.packages = [
            pkgs.wttrbar
            pkgs.swaynotificationcenter
        ];
        
        wayland.windowManager.hyprland.settings = {
            layerrule = [
                "blur,swaync-control-center"
                "blur,swaync-notification-window"
                "ignorezero,swaync-control-center"
                "ignorezero,swaync-notification-window"
                "ignorealpha 0.8,swaync-control-center"
                "ignorealpha 0.8,swaync-notification-window"
            ];
            bindd = [
                "SUPER, N, Open swaync Panel, exec, swaync-client -t "
                "SUPER SHIFT, N, Clear Notifications, exec, swaync-client -C"
            ];
            exec-once = [
                "swaync"
                "waybar"
            ];
        };

        programs.waybar = {
            enable = true;
            package = pkgs.waybar;
            settings = [
                {
                    layer = if waybarBottom then "bottom" else "top";
                    position = if waybarBottom then "bottom" else "top";

                    modules-center = [
                        # "image"
                        # "custom/song"
                        # "custom/lyrics"
                    ];

                    modules-left = [
                        # "window"
                        # "workspaces"
                        "cpu"
                        "disk"
                        "memory"
                        "battery"
                        "clock"
                    ];

                    modules-right = [
                        # "custom/weather"
                        "idle_inhibitor"
                        "pulseaudio"
                        "network"
                        "custom/notification"
                    ];

                    cpu = {
                        interval = 5;
                        format = " {usage:2}%";
                        tooltip = true;
                    };

                    disk = {
                        format = " {free}";
                        tooltip = true;
                    };

                    memory = {
                        interval = 5;
                        format = " {}%";
                        tooltip-format = "RAM: {used:0.1f}GiB/{total:0.1f}GiB ({percentage}%)\nSWAP: {swapUsed:0.1f}GiB/{swapTotal:0.1f}GiB ({swapPercentage}%)";
                        tooltip = true;
                    };

                    battery = {
                        align = 0;
                        rotate = 0;
                        full-at = 100;
                        design-capacity = false;
                        states = {
                            good = 95;
                            warning = 30;
                            critical = 15;
                        };
                        format = "{icon} {capacity}%";
                        format-charging = "󰂄 {capacity}%";
                        format-plugged = "󱘖 {capacity}%";
                        format-alt-click = "click";
                        format-full = "{icon} Full";
                        format-alt = "{icon} {time}";
                        format-icons = [
                            "󰂎"
                            "󰁺"
                            "󰁻"
                            "󰁼"
                            "󰁽"
                            "󰁾"
                            "󰁿"
                            "󰂀"
                            "󰂁"
                            "󰂂"
                            "󰁹"
                        ];
                        format-time = "{H}h {M}min";
                        tooltip = true;
                        tooltip-format = "{timeTo}\nPower Drain: {power}w";
                    };

                    clock = {
                        format = " {:%I:%M %p}";
                        format-alt = " {:%I:%M %p  %Y, %d %B, %A}";
                        tooltip-format = "<tt><small>{calendar}</small></tt>";
                        calendar = {
                            mode = "month";
                            mode-mon-col = 3;
                            weeks-pos = "right";
                            on-scroll = 1;
                            format = {
                                months = "<span color='#ffead3'><b>{}</b></span>";
                                days = "<span color='#ecc6d9'><b>{}</b></span>";
                                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                            };
                        };
                        actions = {
                            on-click-right = "mode";
                            on-scroll-up = "shift_up";
                            on-scroll-down = "shift_down";
                        };
                    };

                    /* >>> CENTER MODULES <<< */

                    # -------------------- BROKEN BECAUSE UNUSED --------------------
                    # --- Lyrics stuff will be added once i switch to the AGS bar ---
                    # ---------------------------------------------------------------

                    # "image" = {
                    #     "interval" = 1;
                    #     "size" = 26;
                    #     "exec" = "node ~/.config/custom-commands/SyncLyrics/media.js --cover";
                    #     "on-click" = "node ~/.config/custom-commands/SyncLyrics/media.js --show-cover";
                    #     "tooltip" = false
                    # };

                    # "custom/song" = {
                    #     "tooltip" = true;
                    #     "format" = "{icon} {0}";
                    #     "format-icons" = {
                    #         "playing" = "󰎇";
                    #         "none" = "󰎊"
                    #     };
                    #     "return-type" = "json";
                    #     "exec-if" = "if [ -f ~/.config/custom-commands/SyncLyrics/media.js ]; then exit 0; else exit 1; fi";
                    #     "restart-interval" = 1;
                    #     "exec" = "node ~/.config/custom-commands/SyncLyrics/media.js --data";
                    #     "on-click" = "node ~/.config/custom-commands/SyncLyrics/media.js --play-toggle";
                    #     "on-click-middle" = "pgrep -x 'spotify' > /dev/null && wmctrl -a 'Spotify' || spotify &";
                    #     "on-scroll-up" = "node ~/.config/custom-commands/SyncLyrics/media.js --volume-up";
                    #     "on-scroll-down" = "node ~/.config/custom-commands/SyncLyrics/media.js --volume-down";
                    #     "escape" = false;
                    #     "exec-on-event" = false
                    # };

                    # "custom/lyrics" = {
                    #     "tooltip" = true;
                    #     "format" = "{icon} {0}";
                    #     "format-icons" = {
                    #         "lyrics" = "󰲹";
                    #         "none" = "󰐓"
                    #     };
                    #     "return-type" = "json";
                    #     "exec-if" = "if [ -f ~/.config/custom-commands/SyncLyrics/media.js ]; then exit 0; else exit 1; fi";
                    #     "restart-interval" = 1;
                    #     "exec" = "node ~/.config/custom-commands/SyncLyrics/media.js";
                    #     "on-click-middle" = "node ~/.config/custom-commands/SyncLyrics/media.js --show-lyrics";
                    #     "escape" = false;
                    #     "hide-empty-text" = true;
                    #     "exec-on-event" = false
                    # };

                    /* >>> RIGHT MODULES <<< */

                    idle_inhibitor = {
                        format = "{icon} ";
                        format-icons = {
                            activated = "";
                            deactivated = "";
                        };
                        tooltip = "true";
                    };

                    pulseaudio = {
                        format = "{volume}% {icon} {format_source}";
                        format-bluetooth = " {volume}% {icon} {format_source}";
                        format-bluetooth-muted = " 󰝟{format_source}";
                        format-muted = "󰝟{format_source}";
                        format-source = " ";
                        format-source-muted = "  ";
                        format-icons = {
                            headphone = "";
                            hands-free = ["" "" ""];
                            headset = ["" "" ""];
                            phone = "";
                            portable = "";
                            car = "";
                            default = ["" "" ""];
                        };
                        on-click-middle = "pavucontrol";
                        on-click = "playerctl play-pause";
                    };

                    network = {
                        interval = 1;
                        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
                        format-ethernet = " {bandwidthDownOctets}";
                        format-wifi = "{icon} {signalStrength}%";
                        format-alt = "{icon} {signalStrength}%  {bandwidthUpBytes}  {bandwidthDownBytes}";
                        format-disconnected = "󰤮";
                        tooltip = false;
                    };

                    "custom/notification" = {
                        tooltip = false;
                        format = "{icon}{0}";
                        format-icons = {
                            notification = "<span foreground='red'><sup></sup></span> ";
                            none = " ";
                            dnd-notification = "<span foreground='red'><sup></sup></span>  ";
                            dnd-none = "  ";
                            inhibited-notification = "<span foreground='red'><sup></sup></span> ";
                            inhibited-none = " ";
                            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>  ";
                            dnd-inhibited-none = "  ";
                        };
                        return-type = "json";
                        exec-if = "which swaync-client";
                        exec = "swaync-client -swb";
                        on-click = "swaync-client -t";
                        escape = true;
                    };
                }
            ];
        };
    };
}