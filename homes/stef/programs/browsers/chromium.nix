{
    config,
    lib,
    username,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.programs.browsers.chromium;
in
{
    options.hmModules.programs.browsers.chromium = {
        enable = mkEnableOption "Enable Chromium";
    };

    config = mkIf cfg.enable {
        wayland.windowManager.hyprland.settings.bindd = [ "SUPER, D, Launch Chromium, exec, chromium" ];
        
        programs.chromium = {
            enable = true;

            extensions = [
                "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
                "dpacanjfikmhoddligfbehkpomnbgblf" # AHA Music - Song Finder for Browser
                "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
                "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
                "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
                "anlikcnbgdeidpacdbdljnabclhahhmd" # Enhanced GitHub
                "dlbdalfhhfecaekoakmanjflmdhmgpea" # Extension Source Downloader
                "fadndhdgpmmaapbmfcknlfgcflmmmieb" # FrankerFaceZ
                "kajibbejlbohfaggdiogboambcijhkke" # Mailvelope - Secure your email with PGP
                "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc" # Material Icons for GitHub
                "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
                "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
                "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
                "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube - Skip Sponsorships
                "naeaaedieihlkmdajjefioajbbdbdjgp" # SVG Export
                "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
                "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
                "djflhoibgkdhkhhcedjiklpkjnoahfmg" # User-Agent Switcher for Chrome
                "licaccaeplhkahfkoighjblahbnafadl" # Viewstats - YouTube video & channel analytics
                "cdockenadnadldjbbgcallicgledbeoc" # VisBug
                {
                    # Zipline Uploads - https://github.com/Stef-00012/Zipline-Upload-Extension/releases/latest/download/ziplineUploads.crx
                    crxPath = "/home/${username}/code/extensions/ziplineUploads/ziplineUploads.crx";
                }
                {
                    # INSSIST (Modified) - https://chromewebstore.google.com/detail/inssist-web-client-for-in/bcocdbombenodlegijagbhdjbifpiijp
                    ctxPath = "/home/${username}/code/extensions/inssist/inssist.crx";
                }
            ];
        };
    };
}