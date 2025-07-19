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
            xdg.enable = true;
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
                enable = true;
                version = "python313";
            };

            javascript = {
                enable = true;
                bun.enable = true;
            };
            
            nix.enable = true;
            misc.enable = true;
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
                land.enable = true;
                idle.enable = true;
                lock.enable = true;
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
                enable = true;
                emulator = "kitty";
            };

            better-control.enable = true;
        };

        styles = {
            qt.enable = true;
            gtk.enable = true;
        };
    };

    home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
        
        packages = with pkgs; [
            pinentry-rofi
        ];

        pointerCursor = {
            gtk.enable = true;
            # x11.enable = true;
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 20;
        };

        sessionVariables = {
            EDITOR = "codium";
        };
    };

    programs.home-manager.enable = true;
}
