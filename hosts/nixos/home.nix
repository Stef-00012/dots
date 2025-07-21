{
    username,
    pkgs,
    ...
}:
{
    imports = [
        ../../homes/${username}
    ];

    hmModules = {
        cli = {
            oh-my-posh.enable = true;

            shell.program = "zsh";
            shell.extraAliases = {
                cls = "clear";
                dim = "du -s -h";
                neofetch = "fastfetch";
                igdownload = "instaloader -l stefanodelprete_ --stories --no-posts --no-metadata-json";
                code = "codium";
            };

            fetch.enable = true;
            fun.enable = true;
            oxidisation.enable = true;
            benchmarking.enable = true;
            utilities.enable = true;
            instagram.enable = true;
            spicetify.enable = false;

            git = {
                enable = true;
                username = "Stef-00012";
                email = "me@stefdp.com";
                signCommits = true;
                signingFormat = "openpgp";
                signingKey = "28BE9A9E4EF0E6BF";
                signByDefault = true;
                github = true;
            };
            
            compression = {
                enable = true;
                zip = true;
                winrar = false;
                gui = false;
            };

            disk-usage.enable = true;
            media.enable = true;
        };

        misc = {
            clipboard.enable = true;
            xdg.enable = true;
            screenshot.enable = true;
            screenrec.enable = true;
            emote.enable = true;

            zipline = {
                enable = true;
                domain = "i.stefdp.com";
                originalName = true;
                overrideDomain = "https://sdp.li";
            };
        };

        dev = {
            python = {
                enable = true;
                version = "python313";
            };

            javascript = {
                enable = true;
                bun.enable = true;
            };
            
            nix.enable = true;
            misc.enable = true;
        };

        programs = {
            browsers = {
                chromium.enable = true;
                firefox.enable = true;
            };
            
            communication = {
                discord = {
                    enable = true;
                    arrpc = true;
                };

                slack.enable = true;
                telegram.enable = true;
                whatsapp.enable = true;
                element.enable = true;
            };

            hypr = {
                land.enable = true;
                idle.enable = true;
                lock.enable = true;
                winwrap.enable = false;
            };

            misc = {
                audacity.enable = false;
                blender.enable = false;
                blockbench.enable = false;
                cheese.enable = true;
                gimp.enable = false;
                gparted.enable = true;
                kdeConnect.enable = true;
                obs-studio.enable = true;
                kate.enable = true;
                syncthing.enable = true;
                realvnc.enable = true;
            };

            editors = {
                vscodium = {
                    enable = true;
                    webdev = true;
                    style = true;
                    github = true;
                    shell = true;
                    markdown = true;
                };

                vim.enable = true;
            };

            widgets = {
                ags.enable = true;
                waybar.enable = false;
            };

            music = {
                spotify.enable = false;

                spicetify = {
                    enable = true;
                    alwaysEnableDevTools = true;
                    experimentalFeatures = true;
                };
            };

            media = {
                enable = true;
                gwenview = true;
                file-roller = true;
                imv = false;
                feh = false;
                qimgv = false;
            };

            terminal = {
                enable = true;
                emulator = "kitty";
            };

            better-control.enable = true;
        };

        styles = {
            qt.enable = true;
            gtk.enable = true;
        };
    };

    home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
        
        packages = with pkgs; [
            pinentry-rofi
        ];

        pointerCursor = {
            gtk.enable = true;
            # x11.enable = true;
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 20;
        };

        sessionVariables = {
            EDITOR = "codium";
        };
    };

    # home.file."test.sh".text = ''
    #     source /var/lib/mailcow-dockerized/mailcow.conf
        
    #     mkdir -m 755 data/web/rc
    #     wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.11/roundcubemail-1.6.11-complete.tar.gz | tar -xvz --no-same-owner -C data/web/rc --strip-components=1 -f -
    #     docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown www-data:www-data /web/rc/logs /web/rc/temp
    #     docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config
    #     docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 750 /web/rc/logs /web/rc/temp /web/rc/config
        
    #     wget -O data/web/rc/config/mime.types http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
        
    #     DBROUNDCUBE=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
    #     echo Database password for user roundcube is $DBROUNDCUBE
    #     docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p''${DBROOT} -e "CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    #     docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p''${DBROOT} -e "CREATE USER 'roundcube'@'%' IDENTIFIED BY '${"\${DBROUNDCUBE}"}';"
    #     docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p''${DBROOT} -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'%';"
        
    #     cat <<EOCONFIG > data/web/rc/config/config.inc.php
    #     <?php
    #     \$config['db_dsnw'] = 'mysql://roundcube:''${DBROUNDCUBE}@mysql/roundcubemail';
    #     \$config['imap_host'] = 'dovecot:143';
    #     \$config['smtp_host'] = 'postfix:588';
    #     \$config['smtp_user'] = '%u';
    #     \$config['smtp_pass'] = '%p';
    #     \$config['support_url'] = ''';
    #     \$config['product_name'] = 'Roundcube Webmail';
    #     \$config['cipher_method'] = 'chacha20-poly1305';
    #     \$config['des_key'] = '$(LC_ALL=C </dev/urandom tr -dc "A-Za-z0-9 !#$%&()*+,-./:;<=>?@[\\]^_{|}~" 2> /dev/null | head -c 32)';
    #     \$config['plugins'] = [
    #       'archive',
    #       'managesieve',
    #       'acl',
    #       'markasjunk',
    #       'zipdownload',
    #       'password',
    #       'carddav',
    #     ];
    #     \$config['spellcheck_engine'] = 'aspell';
    #     \$config['mime_types'] = '/web/rc/config/mime.types';
    #     \$config['enable_installer'] = true;
        
    #     \$config['managesieve_host'] = 'dovecot:4190';
    #     // Enables separate management interface for vacation responses (out-of-office)
    #     // 0 - no separate section (default); 1 - add Vacation section; 2 - add Vacation section, but hide Filters section
    #     \$config['managesieve_vacation'] = 1;
    #     EOCONFIG
        
    #     docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config/config.inc.php
    #     docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 640 /web/rc/config/config.inc.php
        
    #     cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
    #     location /rc/ {
    #       alias /web/rc/public_html/;
    #     }
    #     EOCONFIG
        
    #     rm -r data/web/rc/installer
    #     sed -i -e "s/\(\$config\['enable_installer'\].* = \)true/\1false/" data/web/rc/config/config.inc.php
        
    #     cp -n data/web/rc/composer.json-dist data/web/rc/composer.json
    #     docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
        
    #     docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer audit
        
    #     cat  <<EOCONFIG >> data/conf/dovecot/extra.conf
    #     remote ''${IPV4_NETWORK}.0/24 {
    #       disable_plaintext_auth = no
    #     }
    #     remote ''${IPV6_NETWORK} {
    #       disable_plaintext_auth = no
    #     }
    #     EOCONFIG
        
    #     docker compose restart dovecot-mailcow
        
    #     cat <<EOCONFIG > /var/lib/mailcow-dockerized/docker-compose.override.yml
    #     services:
    #       php-fpm-mailcow:
    #         labels:
    #           ofelia.enabled: "true"
    #           ofelia.job-exec.roundcube_cleandb.schedule: "@every 168h"
    #           ofelia.job-exec.roundcube_cleandb.user: "www-data"
    #           ofelia.job-exec.roundcube_cleandb.command: "/bin/bash -c \"[ -f /web/rc/bin/cleandb.sh ] && /web/rc/bin/cleandb.sh\""
    #     EOCONFIG
    # '';

    programs.home-manager.enable = true;
}
