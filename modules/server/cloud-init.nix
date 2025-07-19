{ config, lib, ... }:
let
    inherit (lib)
        mkIf
        mkOption
        mkEnableOption
        types
        ;
    cfg = config.modules.server.cloud-init;
in
{
    options.modules.server.cloud-init = {
        enable = mkEnableOption "Enable cloud-init";

        name = mkOption {
            type = types.str;
            default = "Cloud Init";
        };
    };

    config = mkIf cfg.enable {
        services.cloud-init = {
            enable = true;
            network.enable
        };
    };
}