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
                enable = true;
                archive-plugin.enable = true;
            };
            hyprland.enable = true;
            appimages.enable = true;
            waydroid.enable = false;
            wireguard = {
                enable = false;
                port = 51820;
            };
            qFlipper.enable = true;
        };

        gaming = {
            enable = true;
            wine.enable = true;
            lutris.enable = true;
            heroic.enable = true;
            bottles.enable = false;
            steam.enable = true;
            minecraft = {
                enable = true;
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

            # Required for your_spotify-api
            mongodb = {
                enable = false;
                port = 27017;
            };

            # Required for your_spotify-web
            your_spotify-api = {
                enable = false;
                domain = "api.spotify.stefdp.com";
                port = 9000;
                icon = "sh:your-spotify";
            };

            your_spotify-web = {
                enable = false;
                domain = "spotify.stefdp.com";
                port = 3000;
                icon = "sh:your-spotify";
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

            # Required for zipline, linkwarden, weblate and umami
            postgresql = {
                enable = false;
                name = "PostgreSQL";
                port = 5432;
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
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/zipline.png";
            };

            umami = {
                enable = false;
                domain = "umami.stefdp.com";
                port = 3011;
            };

            # Required for linkwarden
            meilisearch = {
                enable = false;
                port = 3005;
            };

            linkwarden = {
                enable = false;
                domain = "links.stefdp.com";
                port = 3004;
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/linkwarden.png";
            };

            # BROKEN
            weblate = {
                enable = false;
                domain = "translate.stefdp.com";
                port = 8080;
            };

            convertx = {
                enable = false;
                domain = "convert.stefdp.com";
                port = 3013;
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/convertx.png";
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
                icon = "mdi:music-note";
            };

            likeify = {
                enable = false;
                domain = "likeify.stefdp.com";
                port = 3008;
                icon = "mdi:thumb-up";
            };

            # Required for discord-user-apps
            apprise-api = {
                enable = false;
                # domain = "apprise.stefdp.com";
                port = 3012;
            };

            discord-user-apps = {
                enable = false;
                domain = "bot.stefdp.com";
                port = 3009;
                icon = "sh:discord";
                url = "https://bot.stefdp.com/invite";
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
                icon = "https://create-addons.stefdp.com/favicon.ico";
            };

            personal-site = {
                enable = false;
                domain = "stefdp.com";
                domainAliases = [
                    "www.stefdp.com"
                ];
                port = 3017;
                repoUrl = "https://github.com/Stef-00012/personal-site";
                icon = "https://stefdp.com/icon";
            };

            receiptify = {
                enable = false;
                domain = "receiptify.stefdp.com";
                port = 3018;
                repoUrl = "https://github.com/Stef-00012/receiptify";
                icon = "https://receiptify.stefdp.com/favicon.ico";
            };

            create-addon-notifier-telegram = {
                enable = false;
                repoUrl = "https://github.com/Stef-00012/telegram-create-notifier";
                icon = "sh:telegram";
                url = "https://t.me/CreateAddonsNotifierBot";
            };

            create-addon-notifier-discord = {
                enable = false;
                repoUrl = "https://github.com/Stef-00012/discord-create-notifier";
                icon = "sh:discord";
                url = "https://discord.com/oauth2/authorize?client_id=1390937506710683708&permissions=536870912&integration_type=0&scope=bot+applications.commands";
            };

            api = {
                enable = false;
                domain = "api.stefdp.com";
                port = 3019;
                repoUrl = "https://github.com/Stef-00012/api";
            };

            app-version-control = {
                enable = false;
                domain = "versions.stefdp.com";
                port = 3020;
                repoUrl = "https://github.com/Stef-00012/app-version-control";
            };

            wireguard = {
                enable = false;
                port = 51820;
                interface = "ens3";
            };

            mailcow-dockerized = {
                enable = false;
                domain = "mail.stefdp.com";
                domainAliases = [
                    "autodiscover.mail.stefdp.com"
                    "autoconfig.mail.stefdp.com"
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

    services.fprintd.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan;

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
                "dialout"
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

    fileSystems = {
        "KingSpec" = {
            enable = true;
            device = "/dev/disk/by-uuid/3f85add7-77fd-42c7-9cf8-04191ac85fee";
            fsType = "btrfs";
            mountPoint = "/mnt/kingspec";
            options = [
                "defaults"
                "compress-force=zstd:3"
                "lazytime"
                "commit=120"
                "space_cache=v2"
                "noatime"
                "nofail"
            ];
        };

        "Intenso" = {
            enable = true;
            device = "/dev/disk/by-uuid/4E61-A8A4";
            fsType = "exfat";
            mountPoint = "/mnt/intenso";
            options = [
                "uid=1000"
                "gid=1000"
                "nofail"
            ];
        };

        "Windows SSD" = {
            enable = true;
            device = "/dev/disk/by-uuid/01DA584DF518A4D0";
            fsType = "ntfs";
            mountPoint = "/mnt/windows";
            options = [
                "uid=1000"
                "gid=1000"
                "nofail"
            ];
        };
    };

    swapDevices = [{
        device = "/swapfile";
        size = 16 * 1024; # 16GB
    }];

    systemd.services.fprintd = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    system.stateVersion = "25.05";
}
