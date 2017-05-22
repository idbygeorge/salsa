#Setup

rvm install 2.4.0

gem install bundler

cp /config/deploy/config /config

bundle install

sudo su postgres

##update pg_hba.conf  

vim /etc/postgres/9.5/main/pg_hba.conf

###change first line to:
local   all             postgres                                trust


#Database

##common database commands
\\list - lists all databases
\\connect database_name - connect to a specific database
\\dt - show all tables in connected database

##Migrations
rails generate migration ExplainWhatMigrationDoes

rails db:migrate

rails db:rollback
