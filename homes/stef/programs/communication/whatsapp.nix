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
    cfg = config.hmModules.programs.communication.whatsapp;
in
{
    options.hmModules.programs.communication.whatsapp = {
        enable = mkEnableOption "Install the WhatsApp client";
    };

    config = mkIf cfg.enable {
        home.packages = [
            pkgs.wasistlos
        ];
    };
}