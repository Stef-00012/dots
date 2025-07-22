{
    config,
    lib,
    host,
    ...
}:
let
    inherit (lib)
        mkOption
        mkEnableOption
        types
        mkIf
        filterAttrs
        ;
    cfg = config.modules.server.glance;
    serverModules = config.modules.server;

    sites = builtins.attrValues (
        filterAttrs (_name: mod: mod ? enable && mod.enable == true && (mod ? domain || (mod ? url && mod.url != null))) serverModules
    );

    siteList = builtins.map (mod: {
        title = mod.name or mod.domain;
        url = if mod.url != null then mod.url else "https://${mod.domain}";
        icon = if mod.icon != null then mod.icon else "sh:${lib.strings.replaceStrings [" "] ["-"] (lib.strings.toLower mod.name)}";
    }) sites;
in
{
    options.modules.server.glance = {
        enable = mkEnableOption "Enable glance";

        name = mkOption {
            type = types.str;
            default = "Glance";
        };

        domain = mkOption {
            type = types.str;
            default = "dash.stefdp.com";
            description = "The domain for glance to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for glance";
        };

        port = mkOption {
            type = types.port;
            default = 3001;
            description = "The port for glance to be hosted at";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for glance";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for glance";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                enableACME = true;
                forceSSL = true;

                serverName = cfg.domain;
                serverAliases = cfg.domainAliases;

                locations."/" = {
                    proxyPass = "http://localhost:${toString cfg.port}";
                    extraConfig = ''
                        proxy_set_header Upgrade $http_upgrade;
                        proxy_set_header Connection $http_connection;
                        proxy_http_version 1.1;
                        proxy_set_header Host $host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_set_header X-Forwarded-Proto $scheme;
                    '';
                };
            };
        };
    };
    # maybe in the future https://github.com/glanceapp/community-widgets/blob/main/widgets/google-calendar-list-by-anant-j/README.md
    config = mkIf cfg.enable {
        modules.common.sops.secrets.speedtest-api-key.path = "/var/secrets/speedtest-api-key";
        modules.common.sops.secrets.location.path = "/var/lib/location";

        environment.etc."glance-style.css".text = ''
            body {font-family: Lexend, "Jetbrains Mono", sans-serif, monospace;}
        '';
        services.glance = {
            enable = true;
            settings = {
                # https://github.com/glanceapp/glance/blob/main/docs/configuration.md
                server.port = cfg.port;
                server.proxied = true;
                branding = {
                    app-background-color = "#191724";
                    hide-footer = true;
                };
                    theme = {
                    custom-css-file = "/etc/glance-style.css";
                    background-color = "249 22 12";
                    primary-color = "2 55 83";
                    positive-color = "197 49 38";
                    negative-color = "343 76 68";
                    contrast-multiplier = 1.2;
                    presets.default-dark = {
                        background-color = "249 22 12";
                        primary-color = "2 55 83";
                        positive-color = "197 49 38";
                        negative-color = "343 76 68";
                        contrast-multiplier = 1.2;
                    };
                    presets.default-light = {
                        light = true;
                        background-color = "0 0 95";
                        primary-color = "0 0 10";
                        negative-color = "0 90 50";
                    };
                };
                pages = [
                    {
                        name = host;
                        hide-desktop-navigation = true;
                        show-mobile-header = false;
                        head-widgets = [ ];
                        columns = [
                            {
                                size = "small";
                                widgets = [
                                    {
                                        type = "search";
                                        search-engine = "https://search.stefdp.com/search?q={QUERY}";
                                    }
                                    {
                                        type = "clock";
                                        hour-format = "24h";
                                        title-url = "https://time.is/Rome";
                                        timezones = [
                                            # https://timeapi.io/documentation/iana-timezones
                                            {
                                                timezone = "UTC";
                                                label = "UTC";
                                            }
                                            {
                                                timezone = "Canada/Eastern";
                                                label = "Ottawa";
                                            }
                                            {
                                                timezone = "Asia/Dhaka";
                                                label = "Dhaka";
                                            }
                                        ];
                                    }
                                    {
                                        type = "custom-api";
                                        height = "200px";
                                        title = "Fox";
                                        cache = "2m";
                                        url = "https://randomfox.ca/floof/?ref=public_apis&utm_medium=website";
                                        template = ''<img src="{{ .JSON.String "image" }}"></img>'';
                                    }
                                ];
                            }
                            {
                                size = "full";
                                widgets = [
                                    { type = "to-do"; }
                                    {
                                        type = "server-stats";
                                        servers = [
                                            {
                                                type = "local";
                                                name = host;
                                            }
                                        ];
                                    }
                                    {
                                        type = "monitor";
                                        title = "Services";
                                        cache = "1m";
                                        show-failing-only = false;
                                        sites = siteList;
                                    }
                                ];
                            }
                            {
                                size = "small";
                                widgets = [
                                    {
                                        type = "weather";
                                        location = {
                                            _secret = config.modules.common.sops.secrets.location.path;
                                        };
                                        units = "metric";
                                        hour-format = "24h";
                                        hide-location = true;
                                    }
                                    (mkIf config.modules.server.speedtest-tracker.enable {
                                        type = "custom-api";
                                        cache = "1h";
                                        title = "Internet Speedtest";
                                        title-url = "https://${config.modules.server.speedtest-tracker.domain}";
                                        headers = {
                                            Authorization = {
                                                _secret = config.modules.common.sops.secrets.speedtest-api-key.path;
                                            };
                                            Accept = "application/json";
                                        };
                                        subrequests.stats = {
                                            url = "https://${config.modules.server.speedtest-tracker.domain}/api/v1/stats";
                                            headers = {
                                                Authorization = {
                                                    _secret = config.modules.common.sops.secrets.speedtest-api-key.path;
                                                };
                                                Accept = "application/json";
                                            };
                                        };
                                        options.showPercentageDiff = true;
                                        template = ''
                                            {{ $showPercentage := .Options.BoolOr "showPercentageDiff" true }}
                                            {{ $stats := .Subrequest "stats" }}
                                            <div class="flex justify-between text-center margin-block-3">
                                            <div>
                                                {{ $downloadChange := percentChange ($stats.JSON.Float "data.download.avg_bits") (.JSON.Float "data.download_bits")
                                                }}
                                                {{ if $showPercentage }}
                                                <div
                                                class="size-small {{ if gt $downloadChange 0.0 }}color-positive{{ else if lt $downloadChange 0.0 }}color-negative{{ else }}color-primary{{ end }}"
                                                style="display: inline-flex; align-items: center;">
                                                {{ $downloadChange | printf "%+.1f%%" }}
                                                {{ if gt $downloadChange 0.0 }}
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor"
                                                    style="height: 1em; margin-left: 0.25em;" class="size-4">
                                                    <path fill-rule="evenodd"
                                                    d="M9.808 4.057a.75.75 0 0 1 .92-.527l3.116.849a.75.75 0 0 1 .528.915l-.823 3.121a.75.75 0 0 1-1.45-.382l.337-1.281a23.484 23.484 0 0 0-3.609 3.056.75.75 0 0 1-1.07.01L6 8.06l-3.72 3.72a.75.75 0 1 1-1.06-1.061l4.25-4.25a.75.75 0 0 1 1.06 0l1.756 1.755a25.015 25.015 0 0 1 3.508-2.85l-1.46-.398a.75.75 0 0 1-.526-.92Z"
                                                    clip-rule="evenodd" />
                                                </svg>
                                                {{ else if lt $downloadChange 0.0 }}
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor"
                                                    style="height: 1em; margin-left: 0.25em;" class="size-4">
                                                    <path fill-rule="evenodd"
                                                    d="M1.22 4.22a.75.75 0 0 1 1.06 0L6 7.94l2.761-2.762a.75.75 0 0 1 1.158.12 24.9 24.9 0 0 1 2.718 5.556l.729-1.261a.75.75 0 0 1 1.299.75l-1.591 2.755a.75.75 0 0 1-1.025.275l-2.756-1.591a.75.75 0 1 1 .75-1.3l1.097.634a23.417 23.417 0 0 0-1.984-4.211L6.53 9.53a.75.75 0 0 1-1.06 0L1.22 5.28a.75.75 0 0 1 0-1.06Z"
                                                    clip-rule="evenodd" />
                                                </svg>
                                                {{ end }}
                                                </div>
                                                {{ end }}
                                                <div class="color-highlight size-h3">{{ .JSON.Float "data.download_bits" | mul 0.000001 | printf "%.1f" }}</div>
                                                <div class="size-h6">DOWNLOAD</div>
                                            </div>
                                            <div>
                                                {{ $uploadChange := percentChange ($stats.JSON.Float "data.upload.avg_bits") (.JSON.Float "data.upload_bits") }}
                                                {{ if $showPercentage }}
                                                <div
                                                class="size-small {{ if gt $uploadChange 0.0 }}color-positive{{ else if lt $uploadChange 0.0 }}color-negative{{ else }}color-primary{{ end }}"
                                                style="display: inline-flex; align-items: center;">
                                                {{ $uploadChange | printf "%+.1f%%" }}
                                                {{ if gt $uploadChange 0.0 }}
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor"
                                                    style="height: 1em; margin-left: 0.25em;" class="size-4">
                                                    <path fill-rule="evenodd"
                                                    d="M9.808 4.057a.75.75 0 0 1 .92-.527l3.116.849a.75.75 0 0 1 .528.915l-.823 3.121a.75.75 0 0 1-1.45-.382l.337-1.281a23.484 23.484 0 0 0-3.609 3.056.75.75 0 0 1-1.07.01L6 8.06l-3.72 3.72a.75.75 0 1 1-1.06-1.061l4.25-4.25a.75.75 0 0 1 1.06 0l1.756 1.755a25.015 25.015 0 0 1 3.508-2.85l-1.46-.398a.75.75 0 0 1-.526-.92Z"
                                                    clip-rule="evenodd" />
                                                </svg>
                                                {{ else if lt $uploadChange 0.0 }}
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor"
                                                    style="height: 1em; margin-left: 0.25em;" class="size-4">
                                                    <path fill-rule="evenodd"
                                                    d="M1.22 4.22a.75.75 0 0 1 1.06 0L6 7.94l2.761-2.762a.75.75 0 0 1 1.158.12 24.9 24.9 0 0 1 2.718 5.556l.729-1.261a.75.75 0 0 1 1.299.75l-1.591 2.755a.75.75 0 0 1-1.025.275l-2.756-1.591a.75.75 0 1 1 .75-1.3l1.097.634a23.417 23.417 0 0 0-1.984-4.211L6.53 9.53a.75.75 0 0 1-1.06 0L1.22 5.28a.75.75 0 0 1 0-1.06Z"
                                                    clip-rule="evenodd" />
                                                </svg>
                                                {{ end }}
                                                </div>
                                                {{ end }}
                                                <div class="color-highlight size-h3">{{ .JSON.Float "data.upload_bits" | mul 0.000001 | printf "%.1f" }}</div>
                                                <div class="size-h6">UPLOAD</div>
                                            </div>
                                            <div>
                                                {{ $pingChange := percentChange ($stats.JSON.Float "data.ping.avg") (.JSON.Float "data.ping") }}
                                                {{ if $showPercentage }}
                                                <div
                                                class="size-small {{ if gt $pingChange 0.0 }}color-negative{{ else if lt $pingChange 0.0 }}color-positive{{ else }}color-primary{{ end }}"
                                                style="display: inline-flex; align-items: center;">
                                                {{ $pingChange | printf "%+.1f%%" }}
                                                {{ if lt $pingChange 0.0 }}
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor"
                                                    style="height: 1em; margin-left: 0.25em;" class="size-4">
                                                    <path fill-rule="evenodd"
                                                    d="M1.22 4.22a.75.75 0 0 1 1.06 0L6 7.94l2.761-2.762a.75.75 0 0 1 1.158.12 24.9 24.9 0 0 1 2.718 5.556l.729-1.261a.75.75 0 0 1 1.299.75l-1.591 2.755a.75.75 0 0 1-1.025.275l-2.756-1.591a.75.75 0 1 1 .75-1.3l1.097.634a23.417 23.417 0 0 0-1.984-4.211L6.53 9.53a.75.75 0 0 1-1.06 0L1.22 5.28a.75.75 0 0 1 0-1.06Z"
                                                    clip-rule="evenodd" />
                                                </svg>
                                                {{ else if gt $pingChange 0.0 }}
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor"
                                                    style="height: 1em; margin-left: 0.25em;" class="size-4">
                                                    <path fill-rule="evenodd"
                                                    d="M9.808 4.057a.75.75 0 0 1 .92-.527l3.116.849a.75.75 0 0 1 .528.915l-.823 3.121a.75.75 0 0 1-1.45-.382l.337-1.281a23.484 23.484 0 0 0-3.609 3.056.75.75 0 0 1-1.07.01L6 8.06l-3.72 3.72a.75.75 0 1 1-1.06-1.061l4.25-4.25a.75.75 0 0 1 1.06 0l1.756 1.755a25.015 25.015 0 0 1 3.508-2.85l-1.46-.398a.75.75 0 0 1-.526-.92Z"
                                                    clip-rule="evenodd" />
                                                </svg>
                                                {{ end }}
                                                </div>
                                                {{ end }}
                                                <div class="color-highlight size-h3">{{ .JSON.Float "data.ping" | printf "%.0f ms" }}</div>
                                                <div class="size-h6">PING</div>
                                            </div>
                                            </div>
                                        '';
                                    })
                                    {
                                        type = "custom-api";
                                        title = "Fact";
                                        cache = "15m";
                                        url = "https://uselessfacts.jsph.pl/api/v2/facts/random";
                                        template = ''<p class="size-h4 color-paragraph">{{ .JSON.String "text" }}</p>'';
                                    }
                                ];
                            }
                        ];
                    }
                ];
            };
        };
    };
}