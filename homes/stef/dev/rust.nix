{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.dev.rust;
in
{
    options.hmModules.dev.rust.enable = mkEnableOption "Enable the rust dev module";
    
    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            cargo
        ];
    };
}