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
    cfg = config.hmModules.programs.communication.slack;
in
{
    options.hmModules.programs.communication.slack = {
        enable = mkEnableOption "Install the Slack client";
    };

    config = mkIf cfg.enable {
        home.packages = [
            pkgs.slack
        ];
    };
}