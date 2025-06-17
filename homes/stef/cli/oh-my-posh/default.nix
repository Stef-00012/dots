{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.cli.oh-my-posh;
in
{
    options.hmModules.cli.oh-my-posh = {
        enable = mkEnableOption "Enable oh-my-posh";
    };

    config = mkIf cfg.enable {
        home.packages = [ pkgs.oh-my-posh ];

        # Get themes from https://ohmyposh.dev/docs/themes
        home.file.".config/oh-my-posh/theme.omp.json" = {
            source = ./theme.json;
        };
    }
}