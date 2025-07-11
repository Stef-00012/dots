{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption;
    cfg = config.modules.gaming;

    gamingPackages = with pkgs;
        [ ] # Conditionally include packages based on options
        ++ (lib.optionals cfg.wine.enable [
            wineWow64Packages.wayland
            winetricks
            protontricks
        ])
        ++ (lib.optionals cfg.lutris.enable [ lutris ])
        ++ (lib.optionals cfg.heroic.enable [ heroic ])
        ++ (lib.optionals cfg.bottles.enable [ bottles ])
        ++ (lib.optionals cfg.minecraft.enable [
            prismlauncher
            temurin-jre-bin
        ])
        ++ (lib.optionals cfg.minecraft.modrinth.enable [ modrinth-app ]);
in
{
    options = {
        modules.gaming = {
            enable = mkEnableOption "Enable gaming options";
            wine.enable = mkEnableOption "Enable Wine and associated packages for gaming";
            lutris.enable = mkEnableOption "Enable Lutris for gaming";
            heroic.enable = mkEnableOption "Enable Heroic Games Launcher for gaming";
            bottles.enable = mkEnableOption "Enable Bottles for gaming";
            steam.enable = mkEnableOption "Enable Steam";
            minecraft = {
                enable = mkEnableOption "Enable PrismLauncher for Minecraft" // {
                    default = true;
                };
                modrinth.enable = mkEnableOption "Enable Modrinth Launcher for Minecraft" // {
                    default = false;
                };
            };
        };
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = gamingPackages;

        programs.steam = lib.mkIf cfg.steam.enable {
            enable = true;
            gamescopeSession.enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
        };
    };
}