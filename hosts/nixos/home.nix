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
                # code = "codium";
            };

            fetch.enable = true;
            fun.enable = true;
            oxidisation.enable = true;
            benchmarking.enable = true;
            utilities.enable = true;
            instagram.enable = true;
            spicetify.enable = false;
            rclone.enable = true;

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
            emote.enable = true;

            zipline = {
                enable = true;
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
                eas.enable = true;
            };
            
            nix.enable = true;
            misc.enable = true;
            java.enable = true;
        };

        programs = {
            browsers = {
                chromium.enable = true;
                firefox.enable = true;
            };
            
            communication = {
                discord = {
                    enable = true;
                    arrpc = true;
                };

                slack.enable = true;
                telegram.enable = true;
                whatsapp.enable = true;
                element.enable = true;
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
                cheese.enable = true;
                gimp.enable = true;
                gparted.enable = true;
                kdeConnect.enable = true;
                obs-studio.enable = true;
                kate.enable = true;
                syncthing.enable = true;
                realvnc.enable = true;
                wireguard-gui.enable = false;
            };

            editors = {
                vscode = {
                    enable = true;
                    # webdev = true;
                    # style = true;
                    # github = true;
                    # shell = true;
                    # markdown = true;
                };

                vim.enable = true;
            };

            widgets = {
                ags.enable = true;
                waybar.enable = false;
            };

            music = {
                spotify.enable = false;

                spicetify = {
                    enable = true;
                    alwaysEnableDevTools = true;
                    experimentalFeatures = true;
                };
            };

            media = {
                enable = true;
                gwenview = true;
                file-roller = true;
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
            EDITOR = "code";
        };
    };

    programs.home-manager.enable = true;
}
