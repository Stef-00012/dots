{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.hmModules.misc.screenshot;

    screenshotScript = ''
        #!/usr/bin/env bash
        set -euo pipefail

        usage() {
            echo "Usage: screenshot --ocr|--fullscreen [--swappy]|--area [--swappy]"
            exit 1
        }

        FILENAME="/tmp/screenshot.png"

        OCR=0
        FULLSCREEN=0
        AREA=0
        USE_SWAPPY=0

        while (( $# )); do
        case "$1" in
            --ocr) OCR=1 ;;
            --fullscreen) FULLSCREEN=1 ;;
            --area) AREA=1 ;;
            --swappy) USE_SWAPPY=1 ;;
            *) usage ;;
        esac
        shift
        done

        if (( OCR )); then
            grim -g "$(slurp)" "$FILENAME"
            tesseract -l eng "$FILENAME" - | wl-copy
            rm "$FILENAME"
            exit 0
        fi

        if (( FULLSCREEN || AREA )); then
            wayfreeze & PID=$!
            sleep 0.1

            if (( FULLSCREEN )); then
                grim - | {
                    if (( USE_SWAPPY )); then
                        cat > "$FILENAME"
                        kill $PID
                        swappy -f "$FILENAME" || notify-send "Swappy failed"
                    else
                        wl-copy
                        kill $PID
                        # notify-send "Screenshot copied to clipboard"
                    fi
                }
            else
                GEOM=$(slurp) || { kill $PID; exit 1; } # add this before exit 1 if you want the cancel notif: notify-send "Screenshot cancelled";
                grim -g "$GEOM" - | {
                if (( USE_SWAPPY )); then
                    cat > "$FILENAME"
                    kill $PID
                    swappy -f "$FILENAME" || notify-send "Swappy failed"
                else
                    wl-copy
                    kill $PID
                    # notify-send "Screenshot copied to clipboard"
                fi
                }
            fi
            exit 0
        fi

        usage
    '';
in
{
    options.hmModules.misc.screenshot = {
        enable = mkEnableOption "Enable screenshot script";
    };

    config = mkIf cfg.enable {
        wayland.windowManager.hyprland.settings = {
            bindld = [ ", Print, Fullscreen Screenshot, exec, screenshot --fullscreen --swappy" ];
            
            bindd = [
                "SUPER SHIFT, T, Copy Text From Screenshot, exec, screenshot --ocr"
                "SUPER SHIFT, A, Area Screenshot, exec, screenshot --area --swappy"
                # "SUPER SHIFT, S, Area Screenshot (With Editor), exec, screenshot --area --swappy"
            ];
        };

        home.packages = with pkgs; [
            grim
            slurp
            tesseract
            swappy
            wayfreeze

            (pkgs.writeShellApplication {
                name = "screenshot";

                runtimeInputs = with pkgs; [
                    grim
                    slurp
                    tesseract
                    wl-clipboard
                    swappy
                    wayfreeze
                ];

                text = screenshotScript;
            })
        ];

        home.file.".config/swappy/config".text = ''
            [Default]
            save_dir=${config.xdg.userDirs.pictures}/screenshots
            save_filename_format=%B %d, %Y at %H.%M.%S.png
            show_panel=false
            line_size=5
            text_size=20
            text_font=Lexend
            paint_mode=brush
            early_exit=true
            fill_shape=false
        '';
    };
}