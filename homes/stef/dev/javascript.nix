{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.dev.javascript;
in
{
    options.hmModules.dev.javascript.enable = {
        enable = mkEnableOption "Enable Node.JS";
    };

    options.hmModules.dev.javascript.bun = {
        enable = mkEnableOption "Enable Bun";
    };

    config = mkIf cfg.enable (
        lib.mkMerge [
            {
                home.packages = [
                    pkgs.nodePackages.nodejs
                ]
            }

            (mkIf cfg.bun {
                home.packages = [ pkgs.bun ];
            })
        ]
    );
}