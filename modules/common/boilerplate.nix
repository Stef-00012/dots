{
    config,
    pkgs,
    username,
    group,
    ...
}:
{
    modules.common.sops.secrets = {
        "wakatime.cfg" = {
            path = "/home/${username}/.wakatime.cfg";
            owner = username;
            group = group;
            mode = "0666";
        };

        zipline_token = {
            path = "/home/${username}/.config/zipline/token.key";
            owner = username;
            group = group;
            mode = "0400";
        };

        rclone-gdrive-client-id = {
            path = "/var/secrets/gdrive-client-id";
            owner = username;
            group = group;
            mode = "0400";
        };

        rclone-gdrive-client-secret = {
            path = "/var/secrets/gdrive-client-secret";
            owner = username;
            group = group;
            mode = "0400";
        };

        rclone-gdrive-token = {
            path = "/var/secrets/gdrive-token";
            owner = username;
            group = group;
            mode = "0400";
        };
    };

    boot = {
        # Kernel
        kernelPackages = pkgs.linuxPackages_latest;
        kernelModules = [ "v4l2loopback" ];
        extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
        # Needed For some steam games
        kernel.sysctl = {
            "vm.max_map_count" = 2147483642;
        };

        loader = {
            efi.efiSysMountPoint = "/boot";
            efi.canTouchEfiVariables = true;

            systemd-boot = {
                enable = true;
                consoleMode = "max";
            };

            grub = {
                enable = false;
                device = "nodev";
                useOSProber = true;
                efiSupport = true;
            };
        };

        # Make /tmp a tmpfs
        tmp = {
            useTmpfs = false;
            tmpfsSize = "30%";
        };

        plymouth.enable = true;
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "it_IT.UTF-8";
        LC_IDENTIFICATION = "it_IT.UTF-8";
        LC_MEASUREMENT = "it_IT.UTF-8";
        LC_MONETARY = "it_IT.UTF-8";
        LC_NAME = "it_IT.UTF-8";
        LC_NUMERIC = "it_IT.UTF-8";
        LC_PAPER = "it_IT.UTF-8";
        LC_TELEPHONE = "it_IT.UTF-8";
        LC_TIME = "en_US.UTF-8";
    };

    time.timeZone = "Europe/Rome";

    nixpkgs.config.allowUnfree = true;

    users = {
        mutableUsers = true;
    };

    environment.sessionVariables = {
        NH_FLAKE = "/home/${username}/dots";
        FLAKE = "/home/${username}/dots";
    };

    programs = {
        dconf.enable = true;
        seahorse.enable = true;
        fuse.userAllowOther = true;

        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };

        kdeconnect.enable = true;

        gpu-screen-recorder.enable = true;
    };

    security = {
        rtkit.enable = true;
        polkit.enable = true;

        pam.services.sddm.enableGnomeKeyring = true;

        polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
                if (
                subject.isInGroup("users")
                    && (
                    action.id == "org.freedesktop.login1.reboot" ||
                    action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                    action.id == "org.freedesktop.login1.power-off" ||
                    action.id == "org.freedesktop.login1.power-off-multiple-sessions"
                    )
                )
                {
                return polkit.Result.YES;
                }
            })
        '';
    };

    # Optimization settings and garbage collection automation
    nix = {
        settings = {
            auto-optimise-store = true;

            experimental-features = [
                "nix-command"
                "flakes"
            ];
            
            substituters = [ "https://hyprland.cachix.org" ];
            trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
        };

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
        };
    };

    services = {
        upower.enable = true;

        xserver = {
            enable = false;
            xkb = {
                layout = "it";
                variant = "";
            };
        };

        libinput.enable = true;
        openssh.enable = true;
        gnome.gnome-keyring.enable = true;
    };

    virtualisation.podman = {
        enable = true;
        # dockerCompat = true;
    };

    environment.systemPackages = [ pkgs.distrobox ];

    hardware.graphics.enable = true;

    system.stateVersion = "25.05";
}