{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.dev.java;
in
{
    options.hmModules.dev.java.enable = mkEnableOption "Enable the java dev module";
    
    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            jdk
            android-tools
            # android-studio
        ];
    };
}