{
    username,
    pkgs,
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
                code = "codium";
            };

            fetch.enable = true;
            fun.enable = true;
            oxidisation.enable = true;
            benchmarking.enable = true;
            utilities.enable = true;
            instagram.enable = false;
            spicetify.enable = false;
            rclone.enable = true;

            git = {
                enable = true;
                username = "Stef-00012";
                email = "me@stefdp.com";
                # signCommits = true;
                # signingFormat = "openpgp";
                # signingKey = "28BE9A9E4EF0E6BF";
                # signByDefault = true;
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
            clipboard.enable = false;
            xdg.enable = false;
            screenshot.enable = false;
            screenrec.enable = false;
            emote.enable = false;

            zipline = {
                enable = false;
                domain = "i.stefdp.com";
                originalName = true;
                overrideDomain = "https://sdp.li";
            };
        };

        dev = {
            python = {
                enable = false;
                version = "python313";
            };

            javascript = {
                enable = false;
                bun.enable = false;
            };
            
            nix.enable = false;
            misc.enable = false;
        };

        programs = {
            browsers = {
                chromium.enable = false;
                firefox.enable = false;
            };
            
            communication = {
                discord = {
                    enable = false;
                    arrpc = false;
                };

                slack.enable = false;
                telegram.enable = false;
                whatsapp.enable = false;
                element.enable = false;
            };

            hypr = {
                land.enable = false;
                idle.enable = false;
                lock.enable = false;
                winwrap.enable = false;
            };

            misc = {
                audacity.enable = false;
                blender.enable = false;
                blockbench.enable = false;
                cheese.enable = false;
                gimp.enable = false;
                gparted.enable = false;
                kdeConnect.enable = false;
                obs-studio.enable = false;
                kate.enable = false;
                syncthing.enable = false;
                realvnc.enable = false;
                wireguard-gui.enable = false;
            };

            editors = {
                vscodium = {
                    enable = false;
                    webdev = false;
                    style = false;
                    github = false;
                    shell = false;
                    markdown = false;
                };

                vim.enable = true;
            };

            widgets = {
                ags.enable = false;
                waybar.enable = false;
            };

            music = {
                spotify.enable = false;

                spicetify = {
                    enable = false;
                    alwaysEnableDevTools = false;
                    experimentalFeatures = false;
                };
            };

            media = {
                enable = false;
                gwenview = false;
                file-roller = false;
                imv = false;
                feh = false;
                qimgv = false;
            };

            terminal = {
                enable = false;
                emulator = "kitty";
            };

            better-control.enable = false;
        };

        styles = {
            qt.enable = false;
            gtk.enable = false;
        };
    };

    home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
        
        packages = with pkgs; [
            pinentry-rofi
        ];

        sessionVariables = {
            EDITOR = "vim";
        };
    };

    programs.home-manager.enable = true;
}
