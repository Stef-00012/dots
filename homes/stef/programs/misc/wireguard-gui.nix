{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.misc.wireguard-gui;
in
{
    options.hmModules.programs.misc.wireguard-gui = {
        enable = mkEnableOption "Install wireguard-gui";
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            # inputs.wireguard-gui.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
    };
}