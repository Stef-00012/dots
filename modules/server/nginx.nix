{ config, lib, ... }:
let
    inherit (lib)
        mkEnableOption
        mkIf
        mapAttrs'
        nameValuePair
        filterAttrs
        mkMerge
        mkForce
        mkDefault
        mkAfter
        ;

    cfg = config.modules.server.nginx;

    allModules = config.modules.server or { };
    validModules = filterAttrs (
        _: mod: mod ? nginxConfig && mod.nginxConfig != null && mod ? enable && mod.enable
    ) allModules;

    dynamicVhosts = mapAttrs' (
        _: mod:
        nameValuePair mod.domain mod.nginxConfig
    ) validModules;
in
{
    options.modules.server.nginx.enable = mkEnableOption "Enable Nginx";

    config = mkIf cfg.enable {
        services.nginx = {
            enable = true;
            virtualHosts = dynamicVhosts;
        };

        security.acme = {
            acceptTerms = true;
            defaults.email = "me@stefdp.com";
        };

        networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}