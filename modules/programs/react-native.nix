{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.programs.react-native;
in
{
    options.modules.programs.react-native = {
        enable = mkEnableOption "Enable react-native";
    };

    config = lib.mkIf cfg.enable {
        # Open the port used by expo dev client
        networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}