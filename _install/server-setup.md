# Server setup

This guide is the notes of setting up an AWS instance to run Salsa. It uses a t2.micro instance with 100 GB of storage (don't need as much space if you don't have a lot of documents, or if you host your database on another server)

## Initial Setup (AWS)

Create instance (t2.micro, 100GB SSD)

Generate and add an ssh key for user, use a passphrase as this will allow root level access to the server (save root key somewhere secure, use for backup not routine access)

    vim ~/.ssh/authorized_keys

Add connection to your local computer (replace {{INSTANCE_NAME}} and {{SERVER_IP/HOSTNAME}} with your server's information)

    Host salsa-{{INSTANCE_NAME}}
        HostName {{SERVER_IP/HOSTNAME}}
        User ubuntu
        IdentitiesOnly yes
        IdentityFile ~/.ssh/salsa-{{INSTANCE_NAME}}

Test the new connection

    ssh salsa-{{INSTANCE_NAME}}

## Configure Security Groups

This helps by minimizing potential network based compromises, and only allows your server to be used as a webserver (as intended). There are additional steps needed to fully secure the server, but this is a good set of defaults to start from.

Create salsa-webserver security group (should ONLY allow inbound and outbound HTTP/HTTPS traffic, should only be used for salsa as we use this security group to identify the webserver for the RDS connection)

* Restrict inbound rules to HTTP/HTTPS only
* Remove all outbound rules
* Add outbound HTTP/HTTPS (server updates use HTTPS, could lock this down more)

Create sys-admin security group (should ONLY allow inbound SSH to known IP addresses that you want to allow access to the webserver)

* Restrict inbound rules to SSH to specific IP address
* Remove all outbound rules

Create github-outbound rules to allow gem files/code repository updates

* Remove all outbound rules
* Add rules for port 22, 80, 443, 9418 for 192.30.252.0/22 (https://help.github.com/articles/github-s-ip-addresses/)

Add to know-hosts/test connection to github (should fail before you add github-outbound rule to server)

    ssh -T git@github.com

### Optional, if database is not running on server

Create salsa-database security group

* Remove all outbound rules
* Allow outbound postgresql connections (5432) to database IP address (we set this up later)

## Optional Server Setup

These are optional, but nice to have updates

Turn on eternal history (timestamped history, never expires - super nice to have on servers)

    touch ~/.bash_eternal_history

    vim ~/.bashrc

    # Eternal bash history.
    # ---------------------
    # Undocumented feature which sets the size to "unlimited".
    # http://stackoverflow.com/questions/9457233/unlimited-bash-history
    export HISTFILESIZE=
    export HISTSIZE=
    export HISTTIMEFORMAT="[%F %T] "
    # Change the file location because certain bash sessions truncate .bash_history file upon close.
    # http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
    export HISTFILE=~/.bash_eternal_history
    # Force prompt to write history after every command.
    # http://superuser.com/questions/20900/bash-history-loss
    PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

Logout, login again and make sure your commands are showing up in the ~/.bash_eternal_history file now (or run `history)`)

Set the hostname

    sudo vim /etc/hostname

Add to hosts file

    sudo vim /etc/hosts

    127.0.0.1   localhost {{INSTANCE_NAME}}

Reboot the server and see if it is using the desired hostname now

## Setup Webserver

https://coderwall.com/p/ttrhow/deploying-rails-app-using-nginx-puma-and-capistrano-3

### Dependencies

Setup nginx, git, curl

    sudo apt-get update
    sudo apt-get install curl git-core nginx libpq-dev

### Letsencrypt

Letsencrypt (assumes you want `server.name` as the hostname and the admin email of `admin@example.com` - change to your values)

    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install python-certbot-nginx
    sudo mkdir -p /var/www/html/.well-known/acme-challenge
    sudo certbot certonly --webroot --agree-tos --redirect --renew-by-default --email admin@example.com -w /var/www/html -d salsa.example.com -d www.salsa.example.com

Letsencrypt cron (pick a random minute - example renews 2x every day which is the recommendation)

    sudo crontab -e
    42	*/12	*	*	*	certbot renew --renew-hook "service nginx reload"

### Generate dhparam files

#### Option 1:

Generate a new one (on an AWS EC2 micro instance, this takes 10-40 minutes, based on burst CPU credits available)

    sudo openssl dhparam -out /etc/letsencrypt/archive/salsa.example.com/dhparam1.pem 4096

#### Option 2:

Use pre-generated dhparam (only needed on multi-instance servers where you may want to add more hosts regularly)

    sudo ls -la /etc/letsencrypt/archive/unused
    # pick one (if non are in this folder, add cron task to server to keep a handful of available ones around)
    sudo mv /etc/letsencrypt/archive/unused/dhparam-123.pem /etc/letsencrypt/archive/salsa.example.com/dhparam1.pem
    sudo ln -s /etc/letsencrypt/archive/salsa.example.com/dhparam1.pem /etc/letsencrypt/live/salsa.example.com/dhparam.pem

Setup script to generate upto 10 dhparam files an make them available for use

    mkdir utilities && cd $_
    vim dhparam
    chmod +x dhparam

File contents for ~/apps/utilities/dhparam

    #!/bin/bash

    # generates 10 dhparam keys
    # usage:
    # nohup letsencrypt/dhparam & > /dev/null
    # (`jobs -l` or drop the `> /dev/null` and use `tail -f nohup.out`)

    DIRECTORY=/etc/letsencrypt/archive/unused
    MINKEYS=10
    KEYSIZE=4096

    if [ ! -d $DIRECTORY ]; then
    sudo mkdir -p $DIRECTORY
    fi

    until [ $(ls -l $DIRECTORY | wc -l) -ge "$MINKEYS" ]; do
    DHPARAMFILENAME=$DIRECTORY/dhparam_$RANDOM.pem

    echo "$(ls -l $DIRECTORY | wc -l) keys exist, generating a new one"

    if [ ! -f $DHPARAMFILENAME ]; then
        sudo openssl dhparam -out $DHPARAMFILENAME $KEYSIZE
    else
        echo "file already exists... try again"
        break
    fi
    done

Cron task for generating dhparam files (runs once per day at 00:00 UTC, ensures there are ~10 fresh dhparam files available)

    0	0	*	*	*	/home/ubuntu/utilities/dhparam > /dev/null 2>&1

### Nginx site config

    sudo vim /etc/nginx/sites-available

Default site config (forces https connections, forces https on all subdomains)

*choice of chiphers, forcing https connections and other security settings may not be ideal for every setup, adjust as necessary!*

    server {
      listen 80;
      server_name  salsa.example.com ;

        add_header X-XSS-Protection "1; mode=block";

        add_header Content-Security-Policy "default-src 'self'; script-src 'self'; img-src 'self'; style-src 'self'; font-src 'self'; frame-src 'self'; object-src 'none'";


        rewrite  ^  https://salsa.example.com$request_uri? permanent;
    }

    server {
      listen 443 ssl;

      root /home/ubuntu/apps/salsa/public;
      index index.html index.htm;

      server_name salsa.example.com;

      # certificate/key files, use symlinks to not have to change this config
      # everytime you need to update a cert
      # (letsencrypt will do this for you for all but the dhparam file)
      ssl_certificate         /etc/letsencrypt/live/salsa.example.com/fullchain.pem;
      ssl_certificate_key     /etc/letsencrypt/live/salsa.example.com/privkey.pem;
      ssl_trusted_certificate /etc/letsencrypt/live/salsa.example.com/fullchain.pem;
      ssl_dhparam /etc/letsencrypt/live/salsa.example.com/dhparam.pem;

      # ciphers/protocols to use
      ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
      ssl_prefer_server_ciphers on;

      # other https settings
      ssl_stapling_verify on; # Requires nginx => 1.3.7
      ssl_session_cache shared:SSL:10m;
      ssl_session_tickets off; # Requires nginx >= 1.5.9
      ssl_stapling on; # Requires nginx >= 1.3.7
      resolver 8.8.4.4 8.8.8.8 valid=300s;
      resolver_timeout 5s;

      # forces HTTPS on the domain for 1 year in modern browsers
      add_header Strict-Transport-Security "max-age=63072000;";

      # security headers
      add_header X-Frame-Options DENY;
      add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";

      # letsencrypt will use this for domain verification when issuing/renewing certs
      # using a common path for all sites allows the cert renewal to be the same
      location /.well-known/acme-challenge {
        root /var/www/html;
      }

      location / {
        try_files $uri $uri/ /index.php?$query_string;
      }

      location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param HTTP_PROXY "";
      }



    }

Enable site config

    sudo ln -s /etc/nginx/sites-available/salsa.example.com /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo service nginx reload

Test site: http://salsa.example.com/robots.txt, check certificate https://www.ssllabs.com/ssltest/analyze.html?d=salsa.example.com&hideResults=on&latest


### Ruby

RVM

    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm requirements
    rvm install 2.4.0
    rvm use 2.4.0 --default
    rvm rubygems current

Install Rails/bundler

    gem install rails --no-ri --no-rdoc -V
    gem install bundler --no-ri --no-rdoc -V

Shake hands with Github (if using protected repositories - custom instances)

    ssh -T git@github.com
    ssh -T git@bitbucket.org
    ssh-keygen -t rsa

Node (v7.x)

    curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
    sudo apt install -y nodejs libcurl4-openssl-dev

App setup

    mkdir ~/apps && cd $_
    git clone https://github.com/idbygeorge/salsa.git
    cd salsa
    git checkout upgrade/puma
    gem install bundler
    bundle install
    rake db:create
    rake db:migrate


Setup systemd service/socket

https://github.com/puma/puma/blob/master/docs/systemd.md


    sudo vim /etc/init/puma.service

File contents

    [Unit]
    Description=Puma HTTP Server
    After=network.target

    # Uncomment for socket activation (see below)
    # Requires=puma.socket

    [Service]
    # Foreground process (do not use --daemon in ExecStart or config.rb)
    Type=simple

    # Preferably configure a non-privileged user
    User=www-data

    # Specify the path to your puma application root
    WorkingDirectory=/home/ubuntu/apps/salsa

    # Helpful for debugging socket activation, etc.
    # Environment=PUMA_DEBUG=1

    # The command to start Puma
    # Here we are using a binstub generated via:
    # `bundle binstubs puma --path ./sbin`
    # in the WorkingDirectory (replace <WD> below)
    # You can alternatively use `bundle exec --keep-file-descriptors puma`
    ExecStart=bundle exec --keep-file-descriptors puma

    # Alternatively with a config file (in WorkingDirectory) and
    # comparable `bind` directives
    # ExecStart=<WD>/sbin/puma -C config.rb

    Restart=always

    [Install]
    WantedBy=multi-user.target

... need to figure out how to use socket I think...
and then there is the capistrano stuff?

this doesn't work fully

    # After installing or making changes to puma.service
    systemctl daemon-reload

    # Enable so it starts on boot
    systemctl enable puma.service

    # Initial start up.
    systemctl start puma.service

Dies here

    # Check status
    systemctl status puma.service

    # A normal restart. Warning: listeners sockets will be closed
    # while a new puma process initializes.
    systemctl restart puma.service

Initial capistrano deploy

    # defaults to master if you don't specify the CAPISTRANO_BRANCH env variable
    CAPISTRANO_BRANCH=upgrade/puma cap oasis4he-syllabustool deploy:initial

---------------------------
Get upstart scripts (NOPE)

    cd ~
    wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma-manager.conf
    wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma.conf

Edit setuid and setgid

    setuid www-data
    setgid www-data

Move to `/etc/init` folder

    sudo mv puma.conf puma-manager.conf /etc/init

Create `/etc/puma.conf`

    sudo vim /etc/puma.conf
