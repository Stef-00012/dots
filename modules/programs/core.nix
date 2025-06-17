{
    pkgs,
    ...
}:
{
    environment.systemPackages = with pkgs; [
        lxqt.lxqt-policykit
        xdotool
        libnotify
        libsoup_3
        nh
        nix-output-monitor
        deadnix
        arrpc
        micro
        brightnessctl
        hyprpolkitagent
        hyprland-qtutils
        hyprpicker
        hyprland-qt-support
        usbutils

        rofi # temporary till i make my widget with ags


        # calibre # ebooks BIG 2.1GB
        # obsidian # BIG 1.8GB
        # pinta # half a GB
        # otpclient # half a GB
    ];
}