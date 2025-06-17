{
    pkgs,
    config,
    lib,
    username,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.browsers.firefox;
in
{
    options.hmModules.programs.browsers.firefox = {
        enable = mkEnableOption "Enable firefox";
    };

    config = mkIf cfg.enable {
        programs.firefox = {
            enable = true;

            profiles.${username} = {
                extensions.force = true;
                id = 0;
                isDefault = true;

                search = {
                    default = "Google";
                    force = true;

                    engines = {
                        "Google" = {
                            urls = [ { template = "https://google.com/search?q={searchTerms}"; } ];
                        };

                        "Nix Packages" = {
                            urls = [
                                {
                                    template = "https://search.nixos.org/packages?type=packages&channel=unstable&query={searchTerms}";
                                }
                            ];
                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                            definedAliases = [ "@nixp" ];
                        };

                        "NixOS Wiki" = {
                            urls = [
                                { template = "https://wiki.nixos.org/index.php?search={searchTerms}&title=Special%3ASearch"; }
                            ];
                            icon = "https://wiki.nixos.org/favicon.png";
                            updateInterval = 24 * 60 * 60 * 1000; # every day
                            definedAliases = [ "@nw" ];
                        };

                        "Home-manager Options" = {
                            definedAliases = [ "@nixhm" ];
                            urls = [
                                { template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }
                            ];
                        };

                        "Nix Options" = {
                            definedAliases = [ "@nixm" ];
                            urls = [ { template = "https://search.nixos.org/options?query={searchTerms}"; } ];
                        };

                        "Urban Dictionary" = {
                            definedAliases = [ "@urban" ];
                            urls = [ { template = "https://www.urbandictionary.com/define.php?term={searchTerms}"; } ];
                        };

                        "Youtube" = {
                            definedAliases = [ "@yt" ];
                            urls = [ { template = "https://youtube.com/search?q={searchTerms}"; } ];
                        };

                        "Code Search" = {
                            definedAliases = [ "@gh" ];
                            urls = [ { template = "https://github.com/search?type=code?q={searchTerms}"; } ];
                        };
                    };
                };
            };
        };
    };
}