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
                    "QT_STYLE_OVERRIDE,Adwaita-dark"
                    "SDL_VIDEODRIVER,x11"
                    "MOZ_ENABLE_WAYLAND,1"
                    "EDITOR,code"
                    "GTK_THEME,Adwaita-dark"
                ];

                exec-once = [
                    "systemctl --user start hyprpolkitagent"
                    # "dbus-update-activation-environment --systemd --all"
                    # "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
                    # "lxqt-policykit-agent"
                ];

                bindd =
                    [
                        # Main Bindings
                        "SUPER, E, Open File Manager, exec, thunar"
                        "SUPER, Q, Close Window, killactive,"
                        # "SUPER, M, Exit, exit,"
                        "SUPER, F, Toggle Floating Window, togglefloating,"
                        "SUPER, P, Toggle Dwindle Pseudo, pseudo,"
                        "SUPER, J, Toggle Dwindle Split, togglesplit,"
                        "SUPER ALT, P, Color Picker, exec, hyprpicker -a"

                        # Special Workspace Bindings
                        "SUPER SHIFT, S, Move To Special Workspace (General), movetoworkspace,special"
                        "SUPER, S, Open Special Workspace (General), togglespecialworkspace"

                        # Window Bindings
                        "SUPER, left, Move Focus Left, movefocus,l"
                        "SUPER, right, Move Focus Right, movefocus,r"
                        "SUPER, up, Move Focus Up, movefocus,u"
                        "SUPER, down, Move Focus Down, movefocus,d"
                        "SUPER SHIFT, left, Move Window Left, movewindow,l"
                        "SUPER SHIFT, right, Move Window Right, movewindow,r"
                        "SUPER SHIFT, up, Move Window Up, movewindow,u"
                        "SUPER SHIFT, down, Move Window Down, movewindow,d"
                        "SUPER, B, Blur/Unblur Current Window, exec, hyprctl setprop active opaque toggle # toggle transparency for le active window"

                        # "SUPERSHIFT, APOSTROPHE, Choose Wallpaper, exec, wall-select" # choose a wallpaper
                        # "SUPER, APOSTROPHE, Random Wallpaper, exec, wall-select --fast" # choose a wallpaper
                        # "SUPER, F, Make Window Fullscreen, fullscreen,"
                        # "ALT,Tab, Cycle To Next Window, cyclenext"
                        # "ALT,Tab, Cycle To Next Window, bringactivetotop"
                        
                        # ",XF86Mail, Open Special Workspace, togglespecialworkspace"
                    ]
                    ++
                    # Workspace Bindings: binds SUPER + [shift +] {1..9} to [move to] workspace {1..9}
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

                # Media Bindings
                binddl = [
                    # Mute Speaker
                    ",XF86AudioMute, Mute Audio, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                    ", F19, Mute Audio (Extra Mouse Button - Normal), exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

                    # Mute Microphone
                    ",XF86AudioMicMute, Mute Mic, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                    "ALT, F19, Mute Mic (Extra Mouse Button - G-Shift), exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

                    # Play Media
                    ",XF86AudioPlay, Play Media, exec, playerctl play-pause"
                    ", F16, Play Media (Mouse Extra Button - Normal), exec, playerctl play"

                    # Pause Media
                    ",XF86AudioPause, Pause Media, exec, playerctl play-pause"
                    ", F15, Pause Media (Mouse Extra Button - Normal), exec, playerctl pause"

                    # Next/Previous Media
                    ",XF86AudioNext, Next Media, exec, playerctl next"
                    ",XF86AudioPrev, Previous Media, exec, playerctl previous"
                ];

                # Mouse Window Bindings
                binddm = [
                    "SUPER, mouse:272, Move Window, movewindow"
                    "SUPER, mouse:273, Resize Window, resizewindow"
                ];

                # Workspace Bindings
                bindde = [
                    "SUPER CONTROL, right, Switch To Right Workspace, workspace,e+1"
                    "SUPER CONTROL, left, Switch To Left Workspace, workspace,e-1"
                    "SUPER, mouse_down, Switch To Right Workspace, workspace, e+1"
                    "SUPER, mouse_up, Switch To Left Workspace, workspace, e-1"
                ];

                # Media Bindings
                binddel = [
                    # Raise Speaker Volume
                    ",XF86AudioRaiseVolume, Raise Volume, exec,  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
                    ", F14, Raise Speaker Volume (Extra Mouse Button - Normal), exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"

                    # Lower Speaker Volume
                    ",XF86AudioLowerVolume, Lower Volume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                    ", F13, Lower Speaker Volume (Extra Mouse Button - Normal), exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

                    # Raise/Lower Microphone Volume
                    "ALT, F14, Raise Microphone Volume (Extra Mouse Button - G-Shift), exec,  wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+"
                    "ALT, F13, Lower Microphone Volume (Extra Mouse Button - G-Shift), exec,  wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"

                    # Raise/Lower Brightness
                    ",XF86MonBrightnessUp, Raise Brightness, exec, brightnessctl set +5%"
                    ",XF86MonBrightnessDown, Lower Brightness, exec, brightnessctl set 5%-"
                ];

                monitor = [ ",preferred,auto,1" ];

                # monitorv2 = {
                #     output = "eDP-1";
                #     mode = "preferred";
                #     position = "auto";
                #     scale = 1;
                # };

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
                    sensitivity = -0.4; # -1.0 - 1.0, 0 means no modification.
                    # accel_profile = "flat";
                };

                gesture = [
                    "3, horizontal, workspace"
                    "4, up, fullscreen"
                    "4, down, float"
                ];

                misc = {
                    mouse_move_enables_dpms = true;
                    key_press_enables_dpms = true;
                    focus_on_activate = true;
                };

                cursor = {
                    no_warps = true;
                };

                animations = {
                    enabled = true;

                    bezier = [
                        "wind, 0.05, 0.9, 0.1, 1.05"
                        "winIn, 0.1, 1.1, 0.1, 1.1"
                        "winOut, 0.3, -0.3, 0, 1"
                        "liner, 1, 1, 1, 1"
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

                windowrule = [
                    "opacity 1 override, class:^(Minecraft* 1.21)$"

                    "opacity 0.85 override 0.75 override 0.85 override, class:^(kitty)$"
                    "opacity 0.85 override 0.75 override 0.85 override, class:^(thunar)$"
                    "opacity 0.85 override 0.75 override 0.85 override, initialTitle:^(Open Folder)$"
                    "opacity 0.85 override 0.75 override 0.85 override, class:^(vscode-url-handler)$"

                    # Picture-in-Picture
                    "float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
                    "keepaspectratio, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
                    # "move 73% 72%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$ "
                    "move 59% 6%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$ "
                    # "size 25%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
                    "size 40%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
                    "float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
                    "pin, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"

                    # Dialog windows – float+center these windows.
                    "center, title:^(Open File)(.*)$"
                    "float, title:^(Open File)(.*)$"

                    "center, title:^(Select a File)(.*)$"
                    "float, title:^(Select a File)(.*)$"

                    "center, title:^(Choose wallpaper)(.*)$"
                    "float, title:^(Choose wallpaper)(.*)$"

                    "center, title:^(Open Folder)(.*)$"
                    "float, title:^(Open Folder)(.*)$"

                    "center, title:^(Save As)(.*)$"
                    "float, title:^(Save As)(.*)$"

                    "center, title:^(File Upload)(.*)$"
                    "float, title:^(File Upload)(.*)$"

                    "float, class:^(org.telegram.desktop)$, title:^(Media viewer)$"
                ];

                layerrule = [
                    "noanim, selection"
                ];
            };
        };
    };
}
