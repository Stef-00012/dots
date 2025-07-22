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
        mkIf
        types
        ;
    cfg = config.modules.server.ntfy;
in
{
    options.modules.server.ntfy = {
        enable = mkEnableOption "Enable ntfy";

        name = mkOption {
            type = types.str;
            default = "Ntfy";
        };

        domain = mkOption {
            type = types.str;
            default = "ntfy.stefdp.com";
            description = "The domain for ntfy to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for ntfy";
        };

        port = mkOption {
            type = types.port;
            default = 3003;
            description = "The port for ntfy to be hosted at";
        };

        users = mkOption {
            type = types.listOf (types.submodule {
                options = {
                    username = mkOption {
                        type = types.str;
                        description = "Username for the ntfy user";
                    };

                    role = mkOption {
                        type = types.enum [ "user" "admin" ];
                        description = "Role for the ntfy user (user or admin)";
                    };
                };
            });
            default = [ ];
            description = "List of ntfy users with username and role (user or admin)";
        };

        topics = mkOption {
            type = types.listOf (types.submodule {
                options = {
                    name = mkOption {
                        type = types.str;
                        description = "Name of the ntfy topic";
                    };

                    users = mkOption {
                        type = types.listOf types.str;
                        description = "Usernames for the ntfy topic";
                    };

                    permission = mkOption {
                        type = types.enum [ "read-write" "read-only" "write-only" "deny" ];
                        description = "Permission for the users on this topic";
                    };
                };
            });
            default = [ ];
            description = "List of ntfy topics with username of the user who can access it and with what permission";
        };

        icon = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The icon for ntfy";
        };

        url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL for ntfy";
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

    config = mkIf cfg.enable {
        # File format:
        # user1 = password1
        # user2 = password2
        modules.common.sops.secrets.ntfy-users.path = "/var/secrets/ntfy-users";

        # NTFY_WEB_PUSH_PRIVATE_KEY=xxx
        # modules.common.sops.secrets.ntfy-env.path = "/var/secrets/ntfy-env";

        # systemd.services.ntfy-sh.serviceConfig.EnvironmentFile = "/var/secrets/ntfy-env";

        services.ntfy-sh = {
            enable = true;

            settings = {
                base-url = "https://${cfg.domain}";
                listen-http = ":${toString cfg.port}";

                auth-default-access = "deny-all";
                behind-proxy = true;

                attachment-total-size-limit = "3G";

                # get public and private keys by running "ntfy webpush keys"
                # web-push-public-key = "BAE3cZ3ASBaWasfDpuHhNygp1kvZ0_BfX1y2xtN6pD-hlphLHYs-TBq6fNbwfMpr0fENZkuzxr8CDk2DasvdJG4";
                # web-push-file = /var/lib/ntfy-sh/webpush.db;
                # web-push-email-address = "me@stefdp.com";

                enable-login = true;

                upstream-base-url = "https://ntfy.sh";

                enable-metrics = false;

                log-level = "info";
                log-level-overrides = [
                    "tag=manager -> trace"
                    "emails_received -> trace"
                    "emails_received_failure -> trace"
                    "emails_received_success -> trace"
                    "emails_sent -> trace"
                    "emails_sent_failure -> trace"
                    "emails_sent_success -> trace"
                ];
            };
        };

        systemd.services.ntfy-users = {
            description = "Run ntfy-users app";
            after = [ "ntfy-sh.service" ];
            requires = [ "ntfy-sh.service" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.gcc
                pkgs.vips
                pkgs.openssl_3
                pkgs.ntfy-sh
                pkgs.gawk
                pkgs.findutils
            ];
            serviceConfig = {
                ExecStart = pkgs.writeShellScript "run-ntfy-users" ''
                    ${builtins.concatStringsSep "\n" (
                        map (user: "yes $(cat /var/secrets/ntfy-users | grep ${user.username} | awk -F'=' '{print $2}' | xargs) | ntfy user -c /etc/ntfy/server.yml add --ignore-exists --role=${user.role} ${user.username}") cfg.users
                    )}

                    user_list=$(ntfy user -c /etc/ntfy/server.yml list 2>&1)

                    previous_users=(${builtins.concatStringsSep " " (
                        map (user: "${user.username}") cfg.users
                    )})
                    
                    is_in_previous_users() {
                        local user=$1
                        for prev in "''${previous_users[@]}"; do
                            if [[ "$prev" == "$user" ]]; then
                                return 0
                            fi
                        done
                        return 1
                    }

                    # Read line by line
                    while read -r line; do
                        if [[ $line =~ ^user\ ([^[:space:]]+) ]]; then
                            username="''${BASH_REMATCH[1]}"
                            if [[ "$username" == "*" ]]; then
                                continue
                            fi
                            if ! is_in_previous_users "$username"; then
                                ntfy user -c /etc/ntfy/server.yml remove $username
                            fi
                        fi
                    done <<< "$user_list"

                    ntfy access -c /etc/ntfy/server.yml --reset

                    ${builtins.concatStringsSep "\n" (
                        map (topic: builtins.concatStringsSep "\n" (
                            map (user: "ntfy access -c /etc/ntfy/server.yml ${user} ${topic.name} ${topic.permission}") topic.users
                        )) cfg.topics
                    )}
                '';
                Restart = "no";
            };
        };
    };
}