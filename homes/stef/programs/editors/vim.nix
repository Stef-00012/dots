{
    config,
    pkgs,
    lib,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        types
        mkIf
        ;
    cfg = config.hmModules.programs.editors.vim;
in
{
    options.hmModules.programs.editors.vim = {
        enable = mkEnableOption "Enable Vim";
    };

    config = mkIf cfg.enable {
        home.packages = [
            pkgs.vim
        ];
    };
}