{ config, pkgs, inputs, system, username, ... }:

{
    imports =
        [
            ./hardware.nix
            ../../modules
        ];

    modules = {
        dm.sddm = {
            enable = true;
        };

        programs = {
            thunar = {
                enable = false;
                archive-plugin.enable = false;
            };
            hyprland.enable = true;
            appimages.enable = true;
            waydroid.enable = false;
        };

        gaming = {
            enable = false;
            wine.enable = false;
            lutris.enable = false;
            heroic.enable = false;
            bottles.enable = false;
            steam.enable = false;
            minecraft = {
                enable = false;
                modrinth.enable = false;
            };
        };

        styles = {
            fonts.enable = true;
        };

        common = {
            bluetooth.enable = true;
            printing.enable = true;
            sound.enable = true;
            networking.enable = true;
            virtualisation.enable = false;
            sops.enable = true;
            ssh.enable = true;
        };

        # VPS:

        server = {
            filebrowser = {
                enable = false;
                domain = "fb.stefdp.com";
                port = 5080;
            };

            it-tools = {
                enable = false;
                domain = "tools.stefdp.com";
                port = 3014;
            };

            jellyfin = {
                enable = false;
                domain = "jellyfin.stefdp.com";
                port = 8096;
            };

            ntfy = {
                enable = false;
                domain = "ntfy.stefdp.com";
                port = 3003;
                users = [
                    {
                        username = "stef";
                        role = "admin";
                    }
                ];
                topics = [
                    {
                        name = "compleanni_hemerald";
                        users = [ "everyone" ];
                        permission = "read-only";
                    }
                    {
                        name = "birthdays";
                        users = [ "everyone" ];
                        permission = "read-only";
                    }
                ];
            };

            your_spotify-api = {
                enable = false;
                domain = "api.spotify.stefdp.com";
                port = 9000;
            };
            your_spotify-web = {
                enable = false;
                domain = "spotify.stefdp.com";
                port = 3000;
            };

            speedtest-tracker = {
                enable = false;
                domain = "speedtest.stefdp.com";
                port = 6080;
            };

            glance = {
                enable = false;
                domain = "dash.stefdp.com";
                port = 3001;
            };

            vaultwarden = {
                enable = false;
                domain = "vw.stefdp.com";
                port = 3006;
            };

            zipline = {
                enable = false;
                domain = "i.stefdp.com";
                domainAliases = [
                    "sdp.li"
                    "l.stefdp.com"
                    "stef.likes-ur.mom"
                    "stef.likes-ur.dad"
                    "you-are.part-of.my.id"
                ];
                port = 3002;
            };

            # Required for zipline, linkwarden and umami
            postgresql = {
                enable = false;
                name = "PostgreSQL";
                port = 5432;
            };

            umami = {
                enable = false;
                domain = "umami.stefdp.com";
                port = 3011;
            };

            linkwarden = {
                enable = false;
                domain = "links.stefdp.com";
                port = 3004;
            };

            # Required for linkwarden
            meilisearch = {
                enable = false;
                port = 3005;
            };

            convertx = {
                enable = false;
                domain = "convert.stefdp.com";
                port = 3013;
            };

            syncthing = {
                enable = false;
                domain = "syncthing.stefdp.com";
                port = 8384;
            };

            searxng = {
                enable = false;
                domain = "search.stefdp.com";
                port = 3015;
            };

            grafana = {
                enable = false;
                domain = "grafana.stefdp.com";
                port = 3007;
            };

            prometheus = {
                enable = false;
                port = 9090;
            };

            prometheus-node_exporter = {
                enable = false;
                # domain = "node-exporter.stefdp.com";
                port = 9100;
            };

            lyrics-api = {
                enable = false;
                domain = "lyrics.stefdp.com";
                port = 3010;
            };

            likeify = {
                enable = false;
                domain = "likeify.stefdp.com";
                port = 3008;
            };

            discord-user-apps = {
                enable = false;
                domain = "bot.stefdp.com";
                port = 3009;
            };

            # Required for discord-user-apps
            apprise-api = {
                enable = false;
                # domain = "apprise.stefdp.com";
                port = 3012;
            };

            pi-hole = {
                enable = false;
                # domain = "pi-hole.stefdp.com";
                port = 3007;
            };

            create-addons = {
                enable = false;
                domain = "create-addons.stefdp.com";
                domainAliases = [
                    "create.orangc.net"
                ];
                port = 3016;
                repoUrl = "https://github.com/Stef-00012/create-addons";
            };

            personal-site = {
                enable = false;
                domain = "stefdp.com";
                port = 3017;
                repoUrl = "https://github.com/Stef-00012/personal-site";
            };

            receiptify = {
                enable = false;
                domain = "receiptify.stefdp.com";
                port = 3018;
                repoUrl = "https://github.com/Stef-00012/receiptify";
            };

            create-addon-notifier-telegram = {
                enable = false;
                # domain = "create-addon-notifier-telegram.stefdp.com";
                # port = 3019;
                repoUrl = "https://github.com/Stef-00012/telegram-create-notifier";
            };

            create-addon-notifier-discord = {
                enable = false;
                # domain = "create-addon-notifier-telegram.stefdp.com";
                # port = 3019;
                repoUrl = "https://github.com/Stef-00012/discord-create-notifier";
            };

            api = {
                enable = false;
                domain = "api.stefdp.com";
                port = 3019;
                repoUrl = "https://github.com/Stef-00012/api";
            };

            mailcow-dockerized = {
                enable = false;
                domain = "mail.stefdp.com";
                domainAliases = [
                    "autodiscover.*"
                    "autoconfig.*"
                ];
                port = 7080;
                repoUrl = "https://github.com/mailcow/mailcow-dockerized";
            };

            fail2ban = {
                enable = false;
            };

            cloud-init = {
                enable = false;
            };

            nginx = {
                enable = false;
            };
        };
    };

    local.hardware-clock.enable = true;

    drivers = {
        intel.enable = true;
        amdgpu.enable = false;
        nvidia.enable = false;
        nvidia-prime = {
            enable = false;
            intelBusID = "";
            nvidiaBusID = "";
        };
    };

    time.timeZone = "Europe/Rome";

    console.keyMap = "it2";

    users.users = {
        "${username}" = {
            homeMode = "755";
            isNormalUser = true;
            description = "${username}";
            extraGroups = [
                "networkmanager"
                "wheel"
                "libvirtd"
                "scanner"
                "lp"
                "libvirtd"
                "docker"
            ];
            shell = pkgs.zsh;
            ignoreShellProgramCheck = true;
            packages = with pkgs; [ ];
        };
    };

    environment.systemPackages = with pkgs; [
        pinentry-rofi
    ];

    environment.pathsToLink = [ "/share/zsh" ];

    swapDevices = [{
        device = "/swapfile";
        size = 16 * 1024; # 16GB
    }];

    systemd.services.fprintd = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
    };

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    system.stateVersion = "25.05";
}
