{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.misc.xdg;
    browser = [ "chromium.desktop" ];
    fileManager = [ "thunar.desktop" ];
    editor = [ "codium.desktop" ];

    associations = {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;

        "inode/directory" = fileManager;
        "application/x-xz-compressed-tar" = fileManager;

        "text/*" = editor;
        "audio/*" = [ "mpv.desktop" ];
        "video/*" = [ "mpv.desktop" ];
        "image/*" = [ "gwenview.desktop" ];
        "application/json" = editor;
        "application/pdf" = browser;
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];

        "x-scheme-handler/tg" = [ "telegramdesktop.desktop" ];
        "x-scheme-handler/discord" = [ "discord.desktop" ];
        "x-scheme-handler/mailto" = browser;
    };
in
{
    options.hmModules.misc.xdg = {
        enable = mkEnableOption "Enable XDG";
    };
    
    config = mkIf cfg.enable {
        xdg = {
            configFile."mimeapps.list".force = true;
            enable = true;
            
            cacheHome = "${config.home.homeDirectory}/.cache";
            configHome = "${config.home.homeDirectory}/.config";
            dataHome = "${config.home.homeDirectory}/.local/share";
            stateHome = "${config.home.homeDirectory}/.local/state";

            userDirs = {
                enable = pkgs.stdenv.isLinux;
                createDirectories = true;

                download = "${config.home.homeDirectory}/Downloads";
                desktop = null;
                documents = "${config.home.homeDirectory}/Documents";

                publicShare = null;
                templates = null;

                music = "${config.home.homeDirectory}/Music";
                pictures = "${config.home.homeDirectory}/Pictures";
                videos = "${config.home.homeDirectory}/Videos";

                extraConfig = {
                    XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
                    XDG_MAIL_DIR = "${config.xdg.userDirs.documents}/mail";
                };
            };

            mimeApps = {
                enable = true;
                associations.added = associations;
                defaultApplications = associations;
            };
        };
    };
}