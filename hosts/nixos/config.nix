# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, system, username, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
            ./hardware.nix
            ../../modules
            # inputs.home-manager.nixosModules.default
        ];

    modules = {
        dm.sddm.enable = true;

        common = {
            bluetooth.enable = true;
            printing.enable = true;
            sound.enable = true;
            networking.enable = true;
            virtualisation.enable = false;
            sops.enable = true;
        };

        programs = {
            thunar.enable = true;
            hyprland.enable = true;
            appimages.enable = true;
        };

        gaming = {
            enable = true;
            wine.enable = false;
            lutris.enable = false;
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

    # Bootloader.
    # boot.loader.systemd-boot.enable = true;
    # boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    # boot.kernelPackages = pkgs.linuxPackages_latest;

    # networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    # networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Rome";
    # hardware.logitech.wireless.enable = true;

    # Select internationalisation properties.
    # i18n.defaultLocale = "en_US.UTF-8";

    # i18n.extraLocaleSettings = {
    #     LC_ADDRESS = "it_IT.UTF-8";
    #     LC_IDENTIFICATION = "it_IT.UTF-8";
    #     LC_MEASUREMENT = "it_IT.UTF-8";
    #     LC_MONETARY = "it_IT.UTF-8";
    #     LC_NAME = "it_IT.UTF-8";
    #     LC_NUMERIC = "it_IT.UTF-8";
    #     LC_PAPER = "it_IT.UTF-8";
    #     LC_TELEPHONE = "it_IT.UTF-8";
    #     LC_TIME = "it_IT.UTF-8";
    # };

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    # services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    # services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    # services.xserver.xkb = {
    #     layout = "it";
    #     variant = "";
    # };

    # Configure console keymap
    console.keyMap = "it2";

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable sound with pipewire.
    # services.pulseaudio.enable = false;
    # security.rtkit.enable = true;
    # services.pipewire = {
        # enable = true;
        # alsa.enable = true;
        # alsa.support32Bit = true;
        # pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    # };

    services.fprintd.enable = true; # Enable fingerprint reader support.
    # services.fprintd.tod.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan;

    # services.blueman.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users = {
        "${username}" = {
            homeMode = "755";
            isNormalUser = true;
            description = "${username}";
            # description = "Stefano Del Prete";
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

    # home-manager = {
    #     extraSpecialArgs = {
    #         inherit system;
    #         inherit inputs;
    #     };
    #     users = {
    #         "stef" = import ../home.nix;
    #     };
    # };

    # programs = {
        # Install firefox.
        # firefox.enable = true;
        # hyprland.enable = true;
        # kdeconnect.enable = true;
        # obs-studio.enable = true;

        # zsh.enable = true;

        # git = {
        #     enable = true;
        #     config = {
        #         user = {
        #             name = "Stef-00012";
        #             email = "me@stefdp.com";
        #             #signingkey = "28BE9A9E4EF0E6BF";
        #         };
        #         credential.helper = "store";
        #         pull = {
        #             rebase = "false";
        #             ff = "only";
        #         };
        #         merge.ff = "only";
        #         #commit.gpgsign = "true";
        #     };
        # };
    # };

    # Allow unfree packages
    # nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        pinentry-rofi
        # playerctl
        # pavucontrol
        # xdotool

        # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        # wget
        # gparted
        # fastfetch
        # kitty
        # rofi
        # brightnessctl
        # zip
        # unzip
        # bun
        # nodePackages.nodejs
        # libsoup_3
        # libnotify
        
        # file
        # eza
        # hyprlock
        # hyprpicker
        # hyprpolkitagent
        # hyprland-qtutils
        # xdg-desktop-portal-hyprland
        # hyprland-qt-support
        # wl-clipboard
        # usbutils
        # inputs.astal.packages.${system}.default
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

    # hardware.bluetooth = {
    #     enable = true;
    #     powerOnBoot = true;
    #     settings.General.Experimental = true; # bluetooth percentage
    # };

    # nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
}
