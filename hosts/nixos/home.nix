{
    username,
    ...
}:
{
    imports = [
        ../../homes/${username}
    ];

    hmModules = {
        cli = {
            oh-my-posh.enable = true;

            shell.program = "zsh";
            shell.extraAliases = {
                cls = "clear";
                dim = "du -s -h";
                neofetch = "fastfetch";
                igdownload = "instaloader -l stefanodelprete_ --stories --no-posts --no-metadata-json";
            };

            fetch.enable = true;
            fun.enable = true;
            oxidisation.enable = true;
            benchmarking.enable = true;
            utilities.enable = true;
            instagram.enable = true;
            spicetify.enable = true;

            git = {
                enable = true;
                username = "Stef-00012";
                email = "me@stefdp.com";
                signCommits = true;
                signingFormat = "openpgp";
                signingKey = "28BE9A9E4EF0E6BF";
                signByDefault = true;
                github = true;
            };
            
            compression = {
                enable = true;
                zip = true;
                winrar = false;
                gui = false;
            };

            disk-usage.enable = true;
            media.enable = true;
        };

        misc = {
            clipboard.enable = true;
            xdg.enable = true;
            screenshot.enable = true;
            screenrec.enable = true;
        };

        dev = {
            python = {
                enable = true;
                version = "python313";
            };

            javascript = {
                enable = true;
                bun = true;
            };
            
            nix.enable = true;
            misc.enable = true;
        };

        programs = {
            browsers = {
                chromium.enable = true;
                firefox.enable = true;
            };
            
            communication = {
                discord.enable = true;
                slack.enable = true;
                telegram.enable = true;
            };

            hypr = {
                land.enable = true;
                idle.enable = true;
                lock.enable = true;
            };

            misc = {
                audacity.enable = false;
                blender.enable = false;
                blockbench.enable = false;
                cheese.enable = true;
                gimp.enable = false;
                gparted.enable = true;
                kdeConnect.enable = true;
                obs-studio.enable = true;
                kate.enable = true;
            };

            widgets = {
                ags.enable = true;
            };

            music.spotify.enable = true;

            media = {
                enable = true;
                gwenview = true;
                imv = false;
                feh = false;
                qimfv = false;
            };

            terminal = {
                enable = true;
                emulator = "kitty";
            };

            better-control.enable = true;
        };

        styles = {
            qt.enable = true;
            gtk.enable = true;
            fonts.enable = true;
        };
    };

    home = {
        username = ${username};
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
    };

    home.packages = with pkgs; [
        gnupg
        pinentry-rofi
    ];

    programs.home-manager.enable = true;
}