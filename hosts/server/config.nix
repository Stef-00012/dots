{ config, pkgs, inputs, system, username, ... }:

{
    imports =
        [
            ./hardware.nix
            ../../modules
        ];

    modules = {
        dm.sddm = {
            enable = false;
        };

        programs = {
            thunar = {
                enable = false;
                archive-plugin.enable = false;
            };
            hyprland.enable = false;
            appimages.enable = false;
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
            bluetooth.enable = false;
            printing.enable = false;
            sound.enable = false;
            networking.enable = true;
            virtualisation.enable = false;
            sops.enable = true;
            ssh.enable = true;
        };

        # VPS:

        server = {
            filebrowser = {
                enable = true;
                domain = "fb.stefdp.com";
                port = 5080;
            };

            it-tools = {
                enable = true;
                domain = "tools.stefdp.com";
                port = 3014;
            };

            jellyfin = {
                enable = true;
                domain = "jellyfin.stefdp.com";
                port = 8096;
            };

            ntfy = {
                enable = true;
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
                enable = true;
                domain = "api.spotify.stefdp.com";
                port = 9000;
                icon = "sh:your-spotify";
            };

            your_spotify-web = {
                enable = true;
                domain = "spotify.stefdp.com";
                port = 3000;
                icon = "sh:your-spotify";
            };

            speedtest-tracker = {
                enable = true;
                domain = "speedtest.stefdp.com";
                port = 6080;
            };

            glance = {
                enable = true;
                domain = "dash.stefdp.com";
                port = 3001;
            };

            vaultwarden = {
                enable = true;
                domain = "vw.stefdp.com";
                port = 3006;
            };

            # Required for zipline, linkwarden and umami
            postgresql = {
                enable = true;
                name = "PostgreSQL";
                port = 5432;
            };

            zipline = {
                enable = true;
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
                enable = true;
                domain = "umami.stefdp.com";
                port = 3011;
            };

            # Required for linkwarden
            meilisearch = {
                enable = true;
                port = 3005;
            };

            linkwarden = {
                enable = true;
                domain = "links.stefdp.com";
                port = 3004;
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/linkwarden.png";
            };

            convertx = {
                enable = true;
                domain = "convert.stefdp.com";
                port = 3013;
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/convertx.png";
            };

            syncthing = {
                enable = true;
                domain = "syncthing.stefdp.com";
                port = 8384;
            };

            searxng = {
                enable = true;
                domain = "search.stefdp.com";
                port = 3015;
            };

            grafana = {
                enable = true;
                domain = "grafana.stefdp.com";
                port = 3007;
            };

            prometheus = {
                enable = true;
                port = 9090;
            };

            prometheus-node_exporter = {
                enable = true;
                # domain = "node-exporter.stefdp.com";
                port = 9100;
            };

            lyrics-api = {
                enable = true;
                domain = "lyrics.stefdp.com";
                port = 3010;
            };

            likeify = {
                enable = true;
                domain = "likeify.stefdp.com";
                port = 3008;
            };

            # Required for discord-user-apps
            apprise-api = {
                enable = true;
                # domain = "apprise.stefdp.com";
                port = 3012;
            };

            discord-user-apps = {
                enable = true;
                domain = "bot.stefdp.com";
                port = 3009;
            };

            pi-hole = {
                enable = false;
                # domain = "pi-hole.stefdp.com";
                port = 3007;
            };

            create-addons = {
                enable = true;
                domain = "create-addons.stefdp.com";
                domainAliases = [
                    "create.orangc.net"
                ];
                port = 3016;
                repoUrl = "https://github.com/Stef-00012/create-addons";
                icon = "https://create-addons.stefdp.com/favicon.ico";
            };

            personal-site = {
                enable = true;
                domain = "stefdp.com";
                domainAliases = [
                    "www.stefdp.com"
                ];
                port = 3017;
                repoUrl = "https://github.com/Stef-00012/personal-site";
                icon = "https://stefdp.com/icon";
            };

            receiptify = {
                enable = true;
                domain = "receiptify.stefdp.com";
                port = 3018;
                repoUrl = "https://github.com/Stef-00012/receiptify";
                icon = "https://receiptify.stefdp.com/favicon.ico";
            };

            create-addon-notifier-telegram = {
                enable = true;
                repoUrl = "https://github.com/Stef-00012/telegram-create-notifier";
                icon = "sh:telegram";
            };

            create-addon-notifier-discord = {
                enable = true;
                repoUrl = "https://github.com/Stef-00012/discord-create-notifier";
                icon = "sh:discord";
            };

            api = {
                enable = false;
                domain = "api.stefdp.com";
                port = 3019;
                repoUrl = "https://github.com/Stef-00012/api";
            };

            wireguard = {
                enable = false;
                port = 51820;
                interface = "ens3";
            };

            mailcow-dockerized = {
                enable = true;
                domain = "mail.stefdp.com";
                domainAliases = [
                    "autodiscover.mail.stefdp.com"
                    "autoconfig.mail.stefdp.com"
                ];
                port = 7080;
                repoUrl = "https://github.com/mailcow/mailcow-dockerized";
            };

            fail2ban = {
                enable = true;
            };

            cloud-init = {
                enable = false;
            };

            nginx = {
                enable = true;
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

    environment.variables = {
        TERM = "xterm";
        EDITOR = "vim";
    };

    environment.pathsToLink = [ "/share/zsh" ];

    swapDevices = [{
        device = "/swapfile";
        size = 8 * 1024; # 8GB
    }];

    networking.interfaces.ens3.ipv4.addresses = [
        {
            address = "173.208.137.167";
            prefixLength = 28;
        }
    ];

    networking.interfaces.ens3.ipv6.addresses = [
        {
            address = "2604:4300:a:353:2b9:d7ff:fe5e:d79";
            prefixLength = 64;
        }
    ];

    networking.defaultGateway6 = {
        address = "2604:4300:a:353::1";
        interface = "ens3";
    };

    networking.defaultGateway = "173.208.137.161";
    networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    system.stateVersion = "25.05";
}
