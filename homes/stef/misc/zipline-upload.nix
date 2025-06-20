{
    pkgs,
    config,
    lib,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf types mkOption;
    cfg = config.hmModules.misc.zipline;

    # domain = i.stefdp.com

    uploadScript = ''
        #!/usr/bin/env bash
        set -euo pipefail

        if [[ $# -lt 1 || ! -f "$1" ]]; then
            echo "Error: First argument is missing or not a valid file path." >&2
            exit 1
        fi

        token=$(cat ~/.config/zipline/token.key)

        curl \
            -H "authorization: $token" \
            https://${cfg.domain}/api/upload \
            -F "file=@$1;type=$(file --mime-type -b "$1")" \
            -H 'content-type: multipart/form-data' \
            ${if cfg.compressionPercent != null then ''-H "x-zipline-image-compression-percent: ${toString cfg.compressionPercent}" \'' else ''\''}
            ${if cfg.maxViews != null then ''-H "x-zipline-max-views: ${toString cfg.maxViews}" \'' else ''\''}
            ${if cfg.originalName != null then ''-H "x-zipline-original-name: ${toString cfg.originalName}" \'' else ''\''}
            ${if cfg.overrideDomain != null then ''-H "x-zipline-domain: ${cfg.overrideDomain}" \'' else ''\''}
            | jq -r .files[0].url \
            | wl-copy
    '';
in
{
    options.hmModules.misc.zipline = {
        enable = mkEnableOption "Enable Zipline Upload Script";

        domain = mkOption {
            type = types.str;
            default = "i.stefdp.com";
            description = "Domain to use for the Zipline upload API.";
        };

        compressionPercent = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Compression percent for the uploaded image. If null, no compression is applied.";
        };

        maxViews = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Maximum number of views for the uploaded image. If null, no limit is applied.";
        };

        originalName = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "If true, the original name of the file is used in the upload.";
        };

        overrideDomain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "If set, overrides the domain used for the upload.";
        };
    };

    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            (pkgs.writeShellApplication {
                name = "ziplineupload";

                runtimeInputs = with pkgs; [
                    wl-clipboard
                    file
                ];

                text = uploadScript;
            })
        ];
    };
}