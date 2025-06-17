{ config, pkgs, username, ... }:

{
    imports = [

    ];

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    # home = {
    #     username = ${username};
    #     homeDirectory = "/home/${username}";
    #     stateVersion = "25.05";
    # };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.

    # # home.stateVersion = "25.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
        # kdePackages.kate
        # chromium
        # discord
        # telegram-desktop
        # slack
        # vscode
        # spotify
        # blockbench
        # audacity
        # cheese
        # instaloader
        # oh-my-posh
        # spicetify-cli
        # grim
        # slurp
        # gnupg
        pinentry-rofi

        # blender

        # gimp or gimp3

        #  thunderbird
    ];

    # home.shellAliases = {
    #     exa = "exa";
    #     cls = "clear";
    #     dim = "du -s -h";
    #     neofetch = "fastfetch";
    #     ls = "exa --icons -aF --group-directories-first";
    #     lst = "exa --icons -aF --group-directories-first -T --level=3";
    #     # # lso = "exa --icons -aF1 --group-directories-first";
    #     # # lsot = "exa --icons -aF1 --group-directories-first -T --level=3";
    #     nixrebuild = "sudo nixos-rebuild switch --flake ~/dots/#main";
    #     nixrebuildu = "sudo nixos-rebuild switch --flake ~/dots/#main --upgrade";
    #     igdownload = "instaloader -l stefanodelprete_ --stories --no-posts --no-metadata-json";
    # };

    # programs = {
    #     # git = {
    #     #     enable = true;
    #     #     userName = "Stef-00012";
    #     #     userEmail = "me@stefdp.com";

    #     #     signing = {
    #     #         format = "openpgp";
    #     #         key = "28BE9A9E4EF0E6BF";
    #     #         signByDefault = true;
    #     #     };
    #     # };

    #     # zsh = {
    #     #     enable = true;

    #     #     autosuggestion.enable = true;

    #     #     enableCompletion = true;

    #     #     syntaxHighlighting.enable = true;

    #     #     history = {
    #     #         append = true;
    #     #         ignoreAllDups = true;
    #     #         extended = false;
    #     #         save = 1000;
    #     #         size = 1000;
    #     #     };
    #     # };

    #     # firefox = {
    #     #     enable = true;
    #     # };

    #     # gh = {
    #     #     enable = true;
    #     # };

    #     # obs-studio = {
    #     #     enable = true;
    #     # };
    # };

    # services = {
    #     kdeconnect = {
    #         enable = true;
    #         indicator = true;
    #     };
    # };

    # gtk = {
    #     iconTheme = {
    #         name = "Papirus-Dark";
    #         package = pkgs.papirus-icon-theme;
    #     };
    #     gtk3.extraConfig = {
    #         gtk-application-prefer-dark-theme = 1;
    #     };
    #     gtk4.extraConfig = {
    #         gtk-application-prefer-dark-theme = 1;
    #     };
    # };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/stef/etc/profile.d/hm-session-vars.sh
    #

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # home.sessionVariables = {
    #     # EDITOR = "emacs";
    # };

    # Let Home Manager install and manage itself.
    # programs.home-manager.enable = true;
}
