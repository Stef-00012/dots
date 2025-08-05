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
    options.hmModules.dev.javascript = {
        enable = mkEnableOption "Enable Node.JS";
    };

    options.hmModules.dev.javascript.bun = {
        enable = mkEnableOption "Enable Bun";
    };

    options.hmModules.dev.javascript.eas = {
        enable = mkEnableOption "Enable EAS";
    };

    config = mkIf cfg.enable (
        lib.mkMerge [
            {
                home.packages = [
                    pkgs.nodePackages.nodejs
                ];
            }

            (mkIf cfg.bun.enable {
                home.packages = [ pkgs.bun ];
            })

            (mkIf cfg.eas.enable {
                home.packages = [ pkgs.eas-cli ];
            })
        ]
    );
}