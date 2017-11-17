# Dev Guide - Docker

Copy default configs, adjust as necessary

    cp config/deploy/config/default/* config/

Setup Docker (for postgresql db)

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt-get update
    sudo apt-get install docker-ce

Install docker composer (as root)

    curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

These example Dockerfile and docker-compose.yml expect to be in a folder above the application folder.

../Dockerfile

    FROM ruby:2.4.0

    # set the app directory var
    ENV APP_HOME /home/apps/salsa
    WORKDIR $APP_HOME

    RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
    RUN gem install bundler

    COPY salsa/Gemfile* ./
    RUN bundle install
    ADD . .

../docker-compose.yml

    version: '3'
    services:
      db:
        image: postgres
        volumes:
          - ./salsa/tmp/db/postgres-data:/var/lib/postgresql/data
        ports:
          - "54321:5432"
        environment:
          - POSTGRES_USER:'postgres'
          - POSTGRES_PASSWORD:'postgres'
      salsa:
        environment:
          - TRUSTED_IP=0.0.0.0/0
          - RAILS_ENV=development
        build: .
        command: bundle exec rails s -p 3000 -b '0.0.0.0'
        volumes:
          - .:/home/apps
          - ./salsa/tmp:/tmp
        ports:
          - "3000:3000"
        depends_on:
          - db

Puma File (config/puma.rb)

  copy from config/deploy/development/

  ```
  cp config/deploy/development/puma.rb config/
  ```

Databse config (config/database.yml)

    development:
      adapter: postgresql
      encoding: unicode
      database: salsa_development
      host: db
      username: postgres
      password:
      pool: 5

Make the postgres data folder in the project's tmp folder

    mkdir tmp/db/postgres-data -p

Build (do once for first run, then only if Gemfile or Dockerfile change)

    sudo docker-compose build

Database commands

    sudo docker-compose run salsa rake db:create
    sudo docker-compose run salsa rake db:migrate
    sudo docker-compose run salsa rake db:seed

## Running the application

    sudo docker-compose up

First time for a new hostname (support multi-tennants via differnet hostnames) visit http://0.0.0.0:3000/admin/organizations/new
or just go to http://0.0.0.0:3000/admin/organizations if you have used the database seed command

Slug must be hostname used to access site (i.e. `0.0.0.0` if using http://0.0.0.0:3000/ or `salsa.dev` if using http://salsa.dev:3000/, etc...)

or just go to http://0.0.0.0:3000/admin/organizations if you have used the database seed command

There are already some organizations created if you run the database seed command
there are also documents created but you still need to publish them by going to the abandoned link on the org show page and

## Stopping application

    sudo docker-compose down

## Other useful docker commands

    docker images #list all docker images
    sudo docker rmi ########    #remove docker image id from above command (useful to recreate db or application image if needed)

### Running the queue (que gem)

    sudo docker-compose exec salsa sh
    cd /home/apps/salsa && RAILS_ENV=development que ./config/environment.rb

    #adding a report through rake
    cd /home/apps/salsa && rake RAILS_ENV=development report:generate_report[2,'FL17']

## Logs

Logs are shared with host, so you can view logs via on host via:

    tail -f salsa/logs/*.log
