{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.hypr.land;
in
{
    options.hmModules.programs.hypr.land = {
        enable = mkEnableOption "Enable Hyprland";
    };

    config = mkIf cfg.enable {
        wayland.windowManager.hyprland = {
            enable = true;
            systemd.enable = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            portalPackage =
                inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

            settings = {
                env = [
                    "NIXOS_OZONE_WL,1"
                    "NIXPKGS_ALLOW_UNFREE,1"
                    "XDG_CURRENT_DESKTOP,Hyprland"
                    "XDG_SESSION_TYPE,wayland"
                    "XDG_SESSION_DESKTOP,Hyprland"
                    "GDK_BACKEND,wayland,x11"
                    "CLUTTER_BACKEND,wayland"
                    "QT_QPA_PLATFORM,wayland;xcb"
                    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
                    "QT_AUTO_SCREEN_SCALE_FACTOR,1"
                    "QT_STYLE_OVERRIDE,Adwaita-Dark"
                    "SDL_VIDEODRIVER,x11"
                    "MOZ_ENABLE_WAYLAND,1"
                    "EDITOR,vim"
                ];

                exec-once = [
                    "[workspace special:spotify silent] spotify"
                    "[workspace special:discord silent] discord"
                    "[workspace special:telegram silent] Telegram"
                    "systemctl --user start hyprpolkitagent"
                    # "dbus-update-activation-environment --systemd --all"
                    # "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
                    # "lxqt-policykit-agent"
                    "kdeconnect-indicator"
                ];

                bindd =
                    [
                        "SUPER, E, Open File Manager, exec, dolphin"
                        "SUPER, Q, Close Window, killactive,"
                        "SUPER, M, Exit, exit,"
                        "SUPER, V, Toggle Floating Window, togglefloating,"
                        "SUPER, SPACE, Open Launcher, exec, rofi -show drun"
                        "SUPER, P, Toggle Dwindle Pseudo, pseudo,"
                        "SUPER, J, Toggle Dwindle Split, togglesplit,"
                        "SUPER ALT, C, Color Picker, exec, hyprpicker -a"

                        "SUPER SHIFT, S, Move To Special Workspace (General), movetoworkspace,special"
                        "SUPER, S, Open Special Workspace (General), togglespecialworkspace"

                        "SUPER CONTROL SHIFT, D, Move To Special Workspace (Discord), movetoworkspace, special:discord"
                        "SUPER CONTROL, D, Open Special Workspace (Discord), togglespecialworkspace, discord"

                        "SUPER CONTROL SHIFT, S, Move To Special Workspace (Spotify), movetoworkspace, special:spotify"
                        "SUPER CONTROL, S, Open Special Workspace (Spotify), togglespecialworkspace, spotify"

                        "SUPER CONTROL SHIFT, T, Move To Special Workspace (Telegram), movetoworkspace, special:telegram"
                        "SUPER CONTROL, T, Open Special Workspace (Telegram), togglespecialworkspace, telegram"

                        "SUPER, left, Move Focus Left, movefocus,l"
                        "SUPER, right, Move Focus Right, movefocus,r"
                        "SUPER, up, Move Focus Up, movefocus,u"
                        "SUPER, down, Move Focus Down, movefocus,d"
                        "SUPER SHIFT, left, Move Window Left, movewindow,l"
                        "SUPER SHIFT, right, Move Window Right, movewindow,r"
                        "SUPER SHIFT, up, Move Window Up, movewindow,u"
                        "SUPER SHIFT, down, Move Window Down, movewindow,d"
                        
                        # "SUPER, PERIOD, Select Emoji, exec, emoji-select a"
                        # "SUPERSHIFT, PERIOD, Select Emoji To Clipboard, exec, emoji-select"

                        # "SUPER, C, exec, rofi-calc"
                        # "SUPERSHIFT, APOSTROPHE, Choose Wallpaper, exec, wall-select" # choose a wallpaper
                        # "SUPER, APOSTROPHE, Random Wallpaper, exec, wall-select --fast" # choose a wallpaper
                        # "SUPER, B, Blur/Unblur Current Window, exec, hyprctl setprop active opaque toggle # toggle transparency for le active window"
                        # "SUPERSHIFT, I, Toggle Split, togglesplit"
                        # "SUPERSHIFT, F, Float Current Window, togglefloating"
                        # "SUPER, Q, Close Window, killactive"
                        # "SUPER, F, Make Window Fullscreen, fullscreen,"
                        # ",mouse:275, Scroll Workspace Forward, workspace, e+1"
                        # ",mouse:276,Scroll Workspace Backward, workspace, e-1"
                        # "ALT,Tab, Cycle To Next Window, cyclenext"
                        # "ALT,Tab, Cycle To Next Window, bringactivetotop"
                        
                        # ",XF86Mail, Open Special Workspace, togglespecialworkspace"
                    ]
                    ++
                    # workspaces: binds SUPER + [shift +] {1..9} to [move to] workspace {1..9}
                    (builtins.concatLists (
                        builtins.genList (
                            i:
                                let
                                    ws = i + 1;
                                in
                            [
                                "SUPER, code:1${toString i}, Move To Workspace ${toString ws}, workspace, ${toString ws}"
                                "SUPER SHIFT, code:1${toString i}, Move Window To Workspace ${toString ws}, movetoworkspace, ${toString ws}"
                            ]
                        ) 9
                    ));

                binddl = [
                    ",XF86AudioMute, Mute Audio, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                    ",F16, Mute Audio (Mouse Extra Button), exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

                    ",XF86AudioMicMute, Mute Mic, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                    ",F18, Mute Mic (Mouse Extra Button), exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

                    ",XF86AudioPlay, Play Media, exec, playerctl play-pause"
                    "ALT, F15, Play Media (Mouse Extra Button), exec, playerctl play"

                    ",XF86AudioPause, Pause Media, exec, playerctl play-pause"
                    ",F15, Pause Media (Mouse Extra Button), exec, playerctl pause"

                    ",XF86AudioNext, Next Media, exec, playerctl next"
                    ",XF86AudioPrev, Previous Media, exec, playerctl previous"
                ];

                binddm = [
                    "SUPER, mouse:272, Move Window, movewindow"
                    "SUPER, mouse:273, Resize Window, resizewindow"
                ];

                bindde = [
                    "SUPER CONTROL,right, Switch To Right Workspace, workspace,e+1"
                    "SUPER CONTROL,left, Switch To Left Workspace, workspace,e-1"
                    "SUPER, mouse_down, Switch To Right Workspace, workspace, e+1"
                    "SUPER, mouse_up, Switch To Left Workspace, workspace, e-1"
                ];

                binddel = [
                    ",XF86AudioRaiseVolume, Raise Volume, exec,  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
                    "ALT, F14, Raise Volume (Extra Mouse Button), exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"

                    ",XF86AudioLowerVolume, Lower Volume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                    ", F14, Lower Volume (Extra Mouse Button), exec, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

                    ",XF86MonBrightnessDown, Raise Brightness, exec, brightnessctl set 5%-"
                    ",XF86MonBrightnessUp, Lower Brightness, exec, brightnessctl set +5%"
                ];

                monitor = [ ",preferred,auto,1" ];

                general = {
                    gaps_in = 6;
                    gaps_out = 8;
                    border_size = 0;

                    # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg"
                    # "col.inactive_border" = "rgba(595959aa)"
                    layout = "dwindle";
                    resize_on_border = false;
                    allow_tearing = true;
                };

                input = {
                    kb_layout = "it";
                    kb_variant = ",qwerty";
                    # kb_options = "compose:ins,grp:alt_caps_toggle";
                    kb_options = "fkeys:basic_13-24";
                    follow_mouse = 1;
                    
                    touchpad = {
                        natural_scroll = true;
                    };

                    numlock_by_default = true;
                    sensitivity = -0.5; # -1.0 - 1.0, 0 means no modification.
                    accel_profile = "flat";
                };

                gestures = {
                    workspace_swipe = true;
                    workspace_swipe_fingers = 3;
                };

                misc = {
                    mouse_move_enables_dpms = true;
                    key_press_enables_dpms = true;
                };

                animations = {
                    enabled = true;

                    bezier = [
                        "wind, 0.05, 0.9, 0.1, 1.05"
                        "winIn, 0.1, 1.1, 0.1, 1.1"
                        "winOut, 0.3, -0.3, 0, 1"
                        "liner, 1, 1, 1, 1"

                        # "easeOutQuint,0.23,1,0.32,1"
                        # "easeInOutCubic,0.65,0.05,0.36,1"
                        # "linear,0,0,1,1"
                        # "almostLinear,0.5,0.5,0.75,1.0"
                        # "quick,0.15,0,0.1,1"
                    ];

                    animation = [
                        "windows, 1, 6, wind, slide"
                        "windowsIn, 1, 6, winIn, slide"
                        "windowsOut, 1, 5, winOut, slide"
                        "windowsMove, 1, 5, wind, slide"
                        "border, 1, 1, liner"
                        "borderangle, 1, 30, liner, loop"
                        "fade, 1, 10, default"
                        "workspaces, 1, 5, wind"

                        # "global, 1, 10, default"
                        # "border, 1, 5.39, easeOutQuint"
                        # "windows, 1, 4.79, easeOutQuint"
                        # "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
                        # "windowsOut, 1, 1.49, linear, popin 87%"
                        # "fadeIn, 1, 1.73, almostLinear"
                        # "fadeOut, 1, 1.46, almostLinear"
                        # "fade, 1, 3.03, quick"
                        # "layers, 1, 3.81, easeOutQuint"
                        # "layersIn, 1, 4, easeOutQuint, fade"
                        # "layersOut, 1, 1.5, linear, fade"
                        # "fadeLayersIn, 1, 1.79, almostLinear"
                        # "fadeLayersOut, 1, 1.39, almostLinear"
                        # "workspaces, 1, 1.94, almostLinear, fade"
                        # "workspacesIn, 1, 1.21, almostLinear, fade"
                        # "workspacesOut, 1, 1.94, almostLinear, fade"
                    ];
                };

                decoration = {
                    rounding = 15;

                    blur = {
                        enabled = true;
                        size = 6;
                        passes = 3;
                        popups = false;
                        ignore_opacity = true;
                        new_optimizations = true;
                        xray = true;
                    };

                    inactive_opacity = 0.85;
                    active_opacity = 0.965;
                    fullscreen_opacity = 0.965;
                };

                dwindle = {
                    pseudotile = true;
                    preserve_split = true;
                };

                windowrulev2 = [
                    "opacity 1 override,class:^(Minecraft* 1.21)$"

                    # "opacity 1 override,class:^(zoom)$"
                    "opacity 0.85 override 0.75 override 0.85 override,class:^(kitty)$"
                    "opacity 0.85 override 0.75 override 0.85 override,class:^(thunar)$"
                    "opacity 0.85 override 0.75 override 0.85 override,initialTitle:^(Open Folder)$"
                    "opacity 0.85 override 0.75 override 0.85 override,class:^(codium-url-handler)$"
                    # "opacity 0.85 override 0.75 override 0.85 override,class:^(obsidian)$"
                    # "noblur,class:^(zoom)$"
                    # "stayfocused,class:^(yad)$"

                    # Picture-in-Picture
                    "float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
                    "keepaspectratio, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
                    "move 73% 72%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$ "
                    "size 25%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
                    "float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
                    "pin, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"

                    # Dialog windows – float+center these windows.
                    "center, title:^(Open File)(.*)$"
                    "center, title:^(Select a File)(.*)$"
                    "center, title:^(Choose wallpaper)(.*)$"
                    "center, title:^(Open Folder)(.*)$"
                    "center, title:^(Save As)(.*)$"
                    "center, title:^(File Upload)(.*)$"
                    "float, title:^(Open File)(.*)$"
                    "float, title:^(Select a File)(.*)$"
                    "float, title:^(Choose wallpaper)(.*)$"
                    "float, title:^(Open Folder)(.*)$"
                    "float, title:^(Save As)(.*)$"
                    "float, title:^(File Upload)(.*)$"
                ];
            };
        };
    };
}
