{
    config,
    host,
    username,
    lib,
    ...
}:
let
    inherit (lib)
        mkMerge
        mkOption
        types
        mkIf
        ;

    cfg = config.hmModules.cli.shell;

    commonAliases = {
        ftp = "ncftp";
        clock = "date +'The time is %H.%M on a %A. The date is %b %d, %Y C.E.'";

        # nix stuff
        fr = "nh os switch --hostname ${host} /home/${username}/dots";
        fu = "nh os switch --hostname ${host} --update /home/${username}/dots";
        gcnix = "sudo nh clean all && nix store optimise && sudo journalctl --vacuum-time=1s";
    };

    mergedAliases = mkMerge [
        commonAliases
        cfg.extraAliases
    ];

    sharedInit = ''
        if [ -f /tmp/.current_wallpaper_path ]; then
        export WALLPAPER=$(cat /tmp/.current_wallpaper_path)
        fi
        if [ -f ~/.config/secrets.env ]; then
        export $(grep -v '^#' ~/.config/secrets.env | xargs)
        fi
        export EDITOR=vim
    '';
in
{
    options.hmModules.cli.shell = {
        program = mkOption {
            type = types.nullOr (
                types.enum [
                    "bash"
                    "zsh"
                    "fish"
                ]
            );
            default = null;
            description = "Shell to use and configure (bash, zsh, fish). Leave null to disable.";
        };

        extraAliases = mkOption {
            type = types.attrsOf types.str;
            default = { };
            description = "Extra shell aliases collected from modules.";
        };
    };

    config = mkMerge [
        (mkIf (cfg.program == "bash") {
            programs.bash = {
                enable = true;

                enableCompletion = true;

                initExtra = ''
                    eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/theme.omp.json)"
                    if [ -f $HOME/.bashrc-personal ]; then
                        source $HOME/.bashrc-personal
                    fi
                    ${sharedInit}
                '';

                shellAliases = mergedAliases;
            };
        })

        (mkIf (cfg.program == "zsh") {
            programs.zsh = {
                enable = true;

                autosuggestion.enable = true;
                enableCompletion = true;
                syntaxHighlighting.enable = true;

                initContent = ''
                    eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/theme.omp.json)"
                    [[ -f ~/.zshrc-personal ]] && source ~/.zshrc-personal
                    ${sharedInit}
                '';

                shellAliases = mergedAliases;

                history = {
                    append = true;
                    ignoreAllDups = true;
                    extended = false;
                    save = 1000;
                    size = 1000;
                };
            };
        })

        (mkIf (cfg.program == "fish") {
            programs.command-not-found.dbPath = null;
            programs.fish = {
                enable = true;

                interactiveShellInit = ''
                    set -g fish_greeting
                    oh-my-posh init fish --config ~/.config/oh-my-posh/theme.omp.json | source
                    if test -f /tmp/.current_wallpaper_path
                        set -x WALLPAPER (cat /tmp/.current_wallpaper_path)
                    end
                    if test -f ~/.config/secrets.env
                        for line in (cat ~/.config/secrets.env | grep -v '^#')
                        set -x (string split "=" $line)
                        end
                    end
                '';

                shellAliases = mergedAliases;
            };
        })
    ];
}