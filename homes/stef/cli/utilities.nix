{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;

    cfg = config.hmModules.cli;
in
{
    options.hmModules.cli = {
        fetch.enable = mkEnableOption "Enable fetch programs";
        fun.enable = mkEnableOption "Enable fun CLI programs";
        benchmarking.enable = mkEnableOption "Enable benchmarking tools";
        utilities.enable = mkEnableOption "Enable misc utilities";
        oxidisation.enable = mkEnableOption "Enable drop-in Rust replacements for common CLI tools";
        instagram.enable = mkEnableOption "Enable Instaloader to download media from Instagram";
        spicetify.enable = mkEnableOption "Enable Spicetify to customize Spotify client";
    };

    config = lib.mkMerge [
        (mkIf cfg.fetch.enable {
            home.packages = with pkgs; [
                microfetch
                nitch
                onefetch
                owofetch
                ipfetch
                fastfetch
            ];
        })

        (mkIf cfg.fun.enable {
            home.packages = with pkgs; [
                cmatrix
                lolcat
                kittysay
                uwuify
            ];
        })

        (mkIf cfg.oxidisation.enable {
            home.packages = with pkgs; [
                ripgrep-all
                sd
            ];

            programs = {
                bat.enable = true;
                eza.enable = true;
                fd.enable = true;
                fzf.enable = true;
                ripgrep.enable = true;
                zoxide.enable = true;
            };

            hmModules.cli.shell.extraAliases = {
                cat = "bat";
                find = "fd";
                fuzzy = "fzf";
                cd = "z";
                ".." = "z ..";
                ls = "eza --icons -aF --group-directories-first";
                lst = "eza --icons -aF --group-directories-first -T --level=3";
            };
        })

        (mkIf cfg.benchmarking.enable {
            home.packages = with pkgs; [
                time
                hyperfine
            ];

            hmModules.cli.shell.extraAliases.hf = "hyperfine";
        })

        (mkIf cfg.utilities.enable {
            programs.btop.enable = true;
            home.packages = with pkgs; [
                tokei
                killall
                tree
                libqalculate
                file
                biome
            ];

            hmModules.cli.shell.extraAliases = {
                top = "btop";
            };
        })

        (mkIf cfg.instagram.enable {
            home.packages = with pkgs; [
                instaloader
            ];
        })

        (mkIf cfg.spicetify.enable {
            home.packages = with pkgs; [
                spicetify-cli
            ];
        })
    ];
}