{ config, pkgs, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkOption
        mkIf
        types
        ;
    cfg = config.modules.server.mailcow-dockerized;

    finishScript = pkgs.writeText "mailcow-installer-finish-sh" ''
        cd /var/lib/mailcow-dockerized

        echo "creating nginx config for roundcube"
        
        cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
        location /rc/ {
          alias /web/rc/public_html/;
        }
        EOCONFIG
        
        echo "cleaning up roundcube installer"
        
        rm -r data/web/rc/installer
        sed -i -e "s/\(\$config\['enable_installer'\].* = \)true/\1false/" data/web/rc/config/config.inc.php
        
        echo "updating roundcube composer dependencies"
        
        cp -n data/web/rc/composer.json-dist data/web/rc/composer.json
        docker exec -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
        
        docker exec -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer audit
        
        echo "updating dovecot configuration"
        
        cat  <<EOCONFIG >> data/conf/dovecot/extra.conf
        remote ''${IPV4_NETWORK}.0/24 {
          disable_plaintext_auth = no
        }
        remote ''${IPV6_NETWORK} {
          disable_plaintext_auth = no
        }
        EOCONFIG
        
        docker compose restart dovecot-mailcow
        
        echo "adding roundcube cleandb job"
        
        cat <<EOCONFIG > /var/lib/mailcow-dockerized/docker-compose.override.yml
        services:
          php-fpm-mailcow:
            labels:
              ofelia.enabled: "true"
              ofelia.job-exec.roundcube_cleandb.schedule: "@every 168h"
              ofelia.job-exec.roundcube_cleandb.user: "www-data"
              ofelia.job-exec.roundcube_cleandb.command: "/bin/bash -c \"[ -f /web/rc/bin/cleandb.sh ] && /web/rc/bin/cleandb.sh\""
        EOCONFIG
    '';
in
{
    options.modules.server.mailcow-dockerized = {
        enable = mkEnableOption "Enable mailcow-dockerized";

        name = mkOption {
            type = types.str;
            default = "Create Addons";
        };

        domain = mkOption {
            type = types.str;
            default = "mail.stefdp.com";
            description = "The domain for mailcow-dockerized to be hosted at";
        };

        domainAliases = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Optional list of domain aliases for mailcow-dockerized";
        };

        port = mkOption {
            type = types.port;
            default = 7080;
            description = "The port for mailcow-dockerized to be hosted at";
        };

        repoUrl = mkOption {
            type = types.str;
            default = "https://github.com/mailcow/mailcow-dockerized";
            description = "The Git repository URL for mailcow-dockerized";
        };

        nginxConfig = mkOption {
            type = types.nullOr types.attrs;
            readOnly = true;
            description = "Nginx virtualHost options";
            default = {
                enableACME = true;
                forceSSL = true;
                http2 = true;

                serverName = cfg.domain;
                serverAliases = cfg.domainAliases;

                extraConfig = ''
                    ssl_session_timeout 1d;
                    ssl_session_cache shared:SSL:50m;
                    ssl_session_tickets off;

                    ssl_protocols TLSv1.2;
                    ssl_ciphers HIGH:!aNULL:!MD5:!SHA1:!kRSA;
                    ssl_prefer_server_ciphers off;
                '';

                locations = {
                    "/Microsoft-Server-ActiveSync" = {
                        proxyPass = "http://127.0.0.1:${toString cfg.port}/Microsoft-Server-ActiveSync";
                        extraConfig = ''
                            proxy_set_header Host $host;
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                            proxy_set_header X-Forwarded-Proto $scheme;
                            proxy_connect_timeout 75;
                            proxy_send_timeout 3650;
                            proxy_read_timeout 3650;
                            proxy_buffers 64 512k; # Needed since the 2022-04 Update for SOGo
                            client_body_buffer_size 512k;
                            client_max_body_size 0;
                        '';
                    };

                    "/" = {
                        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
                        extraConfig = ''
                            proxy_set_header Host $host;
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                            proxy_set_header X-Forwarded-Proto $scheme;
                            client_max_body_size 0;

                            proxy_buffer_size 128k;
                            proxy_buffers 64 512k;
                            proxy_busy_buffers_size 512k;
                        '';
                    };
                };
            };
        };
    };

    config = mkIf cfg.enable {
        modules.common.sops.secrets.mailcow-dockerized-env.path = "/var/secrets/mailcow-dockerized-env";

        systemd.tmpfiles.rules = [
            "d /var/lib/mailcow-dockerized 0755 root root -"
            "d /var/lib/mailcow-installer 0755 root root -" 
            "C /var/lib/mailcow-installer/finish.sh 0644 root root - ${finishScript}"
        ];

        virtualisation.docker.enable = true;

        environment.systemPackages = with pkgs; [
            git
            docker
            docker-compose
            gnutar
            wget
            # certbot
        ];

        systemd.services.mailcow-dockerized = {
            description = "Run mailcow-dockerized app";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
                pkgs.git
                pkgs.gcc
                pkgs.vips
                pkgs.wget
                pkgs.docker
                pkgs.docker-compose
                pkgs.gnutar
                pkgs.gzip
            ];
            serviceConfig = {
                WorkingDirectory = "/var/lib/mailcow-dockerized";
                ExecStart = pkgs.writeShellScript "run-mailcow-dockerized" ''
                    if [ "$(ls -A /var/lib/mailcow-dockerized)" ]; then
                        echo "Directory is not empty. Exiting."
                        cd /var/lib/mailcow-dockerized
                        docker compose up -d
                        exit 1
                    fi

                    umask 0022
                    git clone ${cfg.repoUrl} /var/lib/mailcow-dockerized

                    cat <<EOF > /var/lib/mailcow-dockerized/mailcow.conf
                    # Default admin user is "admin"
                    # Default password is "moohoo"

                    MAILCOW_HOSTNAME=mail.stefdp.com
                    MAILCOW_PASS_SCHEME=BLF-CRYPT

                    DBNAME=mailcow
                    DBUSER=mailcow

                    HTTP_PORT=${toString cfg.port}
                    HTTP_BIND=127.0.0.1

                    HTTPS_PORT=7443
                    HTTPS_BIND=127.0.0.1

                    SMTP_PORT=25
                    SMTPS_PORT=465
                    SUBMISSION_PORT=587
                    IMAP_PORT=143
                    IMAPS_PORT=993
                    POP_PORT=110
                    POPS_PORT=995
                    SIEVE_PORT=4190
                    DOVEADM_PORT=127.0.0.1:19991
                    SQL_PORT=127.0.0.1:13306
                    REDIS_PORT=127.0.0.1:7654

                    TZ=Europe/Rome

                    COMPOSE_PROJECT_NAME=mailcowdockerized
                    DOCKER_COMPOSE_VERSION=native

                    ACL_ANYONE=disallow
                    MAILDIR_GC_TIME=7200
                    ADDITIONAL_SAN=
                    AUTODISCOVER_SAN=y
                    ADDITIONAL_SERVER_NAMES=
                    ENABLE_SSL_SNI=n

                    SKIP_LETS_ENCRYPT=n
                    SKIP_IP_CHECK=n
                    SKIP_HTTP_VERIFICATION=n
                    SKIP_UNBOUND_HEALTHCHECK=n
                    SKIP_CLAMD=n
                    SKIP_SOGO=n

                    ALLOW_ADMIN_EMAIL_LOGIN=n

                    USE_WATCHDOG=y
                    WATCHDOG_NOTIFY_BAN=n
                    WATCHDOG_NOTIFY_START=y
                    WATCHDOG_EXTERNAL_CHECKS=n
                    WATCHDOG_VERBOSE=n

                    LOG_LINES=9999

                    IPV4_NETWORK=172.22.1
                    IPV6_NETWORK=fd4d:6169:6c63:6f77::/64

                    MAILDIR_SUB=Maildir

                    SOGO_EXPIRE_SESSION=480

                    # DOVECOT_MASTER_USER and DOVECOT_MASTER_PASS must both be provided. No special chars.
                    # Empty by default to auto-generate master user and password on start.
                    # User expands to DOVECOT_MASTER_USER@mailcow.local
                    # LEAVE EMPTY IF UNSURE
                    DOVECOT_MASTER_USER=
                    # LEAVE EMPTY IF UNSURE
                    DOVECOT_MASTER_PASS=

                    ACME_CONTACT=
                    WEBAUTHN_ONLY_TRUSTED_VENDORS=n
                    SPAMHAUS_DQS_KEY=
                    DISABLE_NETFILTER_ISOLATION_RULE=n

                    FTS_HEAP=128
                    FTS_PROCS=1
                    SKIP_FTS=y
                    HTTP_REDIRECT=n

                    DISABLE_IPv6=n
                    SKIP_OLEFY=n
                    EOF
                    
                    cat /var/secrets/mailcow-dockerized-env >> /var/lib/mailcow-dockerized/mailcow.conf

                    cd /var/lib/mailcow-dockerized
                    docker compose up -d

                    # source /var/lib/mailcow-dockerized/mailcow.conf

                    source /var/lib/mailcow-dockerized/mailcow.conf

                    echo "downloading roundcube"
        
                    mkdir -m 755 data/web/rc
                    wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.11/roundcubemail-1.6.11-complete.tar.gz | tar -xvz --no-same-owner -C data/web/rc --strip-components=1 -f -
                    docker exec $(docker ps -f name=php-fpm-mailcow -q) chown www-data:www-data /web/rc/logs /web/rc/temp
                    docker exec $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config
                    docker exec $(docker ps -f name=php-fpm-mailcow -q) chmod 750 /web/rc/logs /web/rc/temp /web/rc/config
                    
                    echo "downloading mimetypes"

                    wget -O data/web/rc/config/mime.types http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
                    
                    echo "creating roundcube database and user"

                    DBROUNDCUBE=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
                    echo Database password for user roundcube is $DBROUNDCUBE
                    docker exec $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p''${DBROOT} -e "CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
                    docker exec $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p''${DBROOT} -e "CREATE USER 'roundcube'@'%' IDENTIFIED BY '${"\${DBROUNDCUBE}"}';"
                    docker exec $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p''${DBROOT} -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'%';"
                    
                    echo "creating roundcube config file"

                    cat <<EOCONFIG > data/web/rc/config/config.inc.php
                    <?php
                    \$config['db_dsnw'] = 'mysql://roundcube:''${DBROUNDCUBE}@mysql/roundcubemail';
                    \$config['imap_host'] = 'dovecot:143';
                    \$config['smtp_host'] = 'postfix:588';
                    \$config['smtp_user'] = '%u';
                    \$config['smtp_pass'] = '%p';
                    \$config['support_url'] = ''';
                    \$config['product_name'] = 'Roundcube Webmail';
                    \$config['cipher_method'] = 'chacha20-poly1305';
                    \$config['des_key'] = '$(LC_ALL=C </dev/urandom tr -dc "A-Za-z0-9 !#$%&()*+,-./:;<=>?@[\\]^_{|}~" 2> /dev/null | head -c 32)';
                    \$config['plugins'] = [
                      'archive',
                      'managesieve',
                      'acl',
                      'markasjunk',
                      'zipdownload',
                      'password',
                      'carddav',
                    ];
                    \$config['spellcheck_engine'] = 'aspell';
                    \$config['mime_types'] = '/web/rc/config/mime.types';
                    \$config['enable_installer'] = true;
                    
                    \$config['managesieve_host'] = 'dovecot:4190';
                    // Enables separate management interface for vacation responses (out-of-office)
                    // 0 - no separate section (default); 1 - add Vacation section; 2 - add Vacation section, but hide Filters section
                    \$config['managesieve_vacation'] = 1;
                    EOCONFIG
                    
                    docker exec $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config/config.inc.php
                    docker exec $(docker ps -f name=php-fpm-mailcow -q) chmod 640 /web/rc/config/config.inc.php

                    echo "=========== !! IMPORTANT !! ==========="
                    echo "Visit https://${cfg.domain}/rc/installer and make sure everything is set to 'OK' (some 'NOT AVAILABLE' are expected)"
                    echo "If there is no 'NOT OK', run the following script as root:"
                    echo "/var/lib/mailcow-installer/finish.sh"
                    echo "=========== !! IMPORTANT !! ==========="

                    # docker compose up -d
                '';
                # ExecStopPost = pkgs.writeShellScript "stop-mailcow-dockerized" ''
                #     cd /var/lib/mailcow-dockerized
                #     docker compose down
                # '';
                Restart = "no";
            };
        };

        networking.firewall.allowedTCPPorts = [
            25
            465
            587
            143
            993
            110
            995
            4190
        ];
    };
}