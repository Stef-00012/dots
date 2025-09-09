{ lib, ... }:
{
    options.hmModules.programs.editors.xdg = lib.mkOption {
        type = lib.types.str;
        default = "vscode";
        description = "The .desktop filename to use for XDG";
    };

    imports = [
        ./vscode.nix
        ./vim.nix
    ];
}
