{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkOption
        types
        mkIf
        ;

    cfg = config.hmModules.programs.editors.vscodium;
in
{
    options.hmModules.programs.editors.vscodium = {
        enable = mkEnableOption "Enable VSCodium";

        webdev = mkOption {
            type = types.bool;
            default = false;
            description = "Enable web development extensions.";
        };

        style = mkOption {
            type = types.bool;
            default = false;
            description = "Enable styling extensions.";
        };

        github = mkOption {
            type = types.bool;
            default = false;
            description = "Enable github extensions.";
        };

        shell = mkOption {
            type = types.bool;
            default = false;
            description = "Enable shell extensions.";
        };

        markdown = mkOption {
            type = types.bool;
            default = false;
            description = "Enable markdown extensions.";
        };
    };

    config = mkIf cfg.enable {
        programs.vscode = {
            enable = true;
            package = pkgs.vscodium;

            profiles.default = {
                userSettings = lib.mkForce {
                    "workbench.colorTheme" = "Default Dark+";
                    "workbench.editor.enablePreview" = false;
                    "[javascript]" = {
                        "editor.defaultFormatter" = "biomejs.biome";
                    };
                    "workbench.iconTheme" = "material-icon-theme";
                    "explorer.confirmDelete" = false;
                    "explorer.confirmDragAndDrop" = false;
                    "[typescriptreact]" = {
                        "editor.defaultFormatter" = "biomejs.biome";
                    };
                    "[json]" = {
                        "editor.defaultFormatter" = "biomejs.biome";
                    };
                    "[typescript]" = {
                        "editor.defaultFormatter" = "biomejs.biome";
                    };
                    "window.zoomLevel" = 1;
                    "markdown-preview-enhanced.previewTheme" = "atom-dark.css";
                    "markdown-preview-enhanced.codeBlockTheme" = "atom-dark.css";
                    "liveServer.settings.donotShowInfoMsg" = true;
                    "[jsonc]" = {
                        "editor.defaultFormatter" = "biomejs.biome";
                    };
                    "git.openRepositoryInParentFolders" = "never";
                    "[css]" = {
                        "editor.defaultFormatter" = "biomejs.biome";
                    };
                    "workbench.startupEditor" = "none";
                    "svelte.ask-to-enable-ts-plugin" = false;
                    "github.copilot.enable" = {
                        "*" = true;
                        "plaintext" = false;
                        "markdown" = false;
                        "scminput" = false;
                    };
                    "template-string-converter.autoRemoveTemplateString" = true;
                    "template-string-converter.addBracketsToProps" = true;
                    "typescript.updateImportsOnFileMove.enabled" = "always";
                    "svg.preview.mode" = "svg";
                    "diffEditor.ignoreTrimWhitespace" = false;
                    "workbench.editorAssociations" = {
                        "*.copilotmd" = "vscode.markdown.preview.editor";
                        "*.svg" = "default";
                    };
                    "[svg]" = {
                        "editor.defaultFormatter" = "jock.svg";
                    };
                    "security.workspace.trust.untrustedFiles" = "open";
                    "editor.fontFamily" = "FiraCode Nerd Font";
                    "redhat.telemetry.enabled" = false;
                    "editor.tabSize" = 4;
                };

                keybindings = [
                    {
                        key = "ctrl+[Backslash]";
                        command = "editor.action.commentLine";
                        when = "editorTextFocus && !editorReadonly";
                    }
                    {
                        key = "ctrl+[Equal]";
                        command = "editor.action.indentLines";
                    }
                    {
                        key = "ctrl+[Minus]";
                        command = "editor.action.outdentLines";
                    }
                ];

                extensions = with pkgs.vscode-extensions;
                    let
                        extensions = [
                            wakatime.vscode-wakatime
                            leonardssh.vscord
                            biomejs.biome
                            usernamehw.errorlens
                            eamodio.gitlens
                            wix.vscode-import-cost
                            ms-vsliveshare.vsliveshare
                            jock.svg
                            meganrogge.template-string-converter
                            gruntfuggly.todo-tree
                            redhat.vscode-xml
                        ];

                        styleExtensions = lib.optionals cfg.style [
                            johnpapa.vscode-peacock
                            pkief.material-icon-theme
                            oderwat.indent-rainbow
                        ];

                        githubExtensions = lib.optionals cfg.github [
                            github.vscode-github-actions
                            github.copilot
                            github.copilot-chat
                        ];

                        shellExtensions = lib.optionals cfg.shell [
                            timonwong.shellcheck
                        ];

                        nixExtensions = lib.optionals config.hmModules.dev.nix.enable [
                            jnoortheen.nix-ide
                        ];

                        markdownExtensions = lib.optionals cfg.markdown [
                            shd101wyy.markdown-preview-enhanced
                        ];

                        pythonExtensions = lib.optionals config.hmModules.dev.python.enable [
                            ms-python.python
                        ];
                        
                        webdevExtensions = lib.optionals cfg.webdev [
                            ecmel.vscode-html-css
                            bradlc.vscode-tailwindcss
                            ritwickdey.liveserver
                        ];
                    in
                        extensions ++ webdevExtensions ++ nixExtensions ++ pythonExtensions ++ styleExtensions ++ githubExtensions ++ markdownExtensions;
            };
        };
    };
}