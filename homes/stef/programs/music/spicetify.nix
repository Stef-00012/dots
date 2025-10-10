{
    config,
    lib,
    inputs,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf mkOption types;
    cfg = config.hmModules.programs.music.spicetify;

    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
    imports = [
        inputs.spicetify-nix.homeManagerModules.spicetify 
    ];

    options.hmModules.programs.music.spicetify = {
        enable = mkEnableOption "Install the Spotify Client modded with Spicetify";

        alwaysEnableDevTools = mkOption {
            type = types.bool;
            default = false;
            description = "Always enable DevTools.";
        };

        experimentalFeatures = mkOption {
            type = types.bool;
            default = false;
            description = "Enable experimental features.";
        };
    };

    config = mkIf cfg.enable {
        wayland.windowManager.hyprland.settings = {
            exec-once = [
                "[workspace special:spotify silent] spotify"
            ];

            bindd = [
                "SUPER CONTROL SHIFT, S, Move To Special Workspace (Spotify), movetoworkspace, special:spotify"
                "SUPER CONTROL, S, Open Special Workspace (Spotify), togglespecialworkspace, spotify"
            ];

            windowrule = [
                "workspace special:spotify , class:^(spotify)$"
            ];
        };

        programs.spicetify = {
            enable = true;

            enabledExtensions = with spicePkgs.extensions; [
                fullAppDisplay
                fullAppDisplayMod
                popupLyrics
                shuffle # shuffle+ (special characters are sanitized out of extension names)
                fullAlbumDate
                songStats
                showQueueDuration
                copyToClipboard
                history
                adblock
                volumePercentage
                beautifulLyrics
                lastfm
                betterGenres
            ];

            alwaysEnableDevTools = cfg.alwaysEnableDevTools;
            experimentalFeatures = cfg.experimentalFeatures;

            enabledCustomApps = with spicePkgs.apps; [
                lyricsPlus
                marketplace
            ];

            wayland = true;
            theme = spicePkgs.themes.defaultDynamic;
        };
    };
}