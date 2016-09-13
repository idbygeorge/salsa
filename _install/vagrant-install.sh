sudo apt-get install -y libpq-dev
cd /vagrant
rvm install ruby-2.3.1
gem install bundler

bundle

#### temp....
#$ bin/rails generate que:install
#$ bin/rake db:migrate


# pg configs didn't run....

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.5/main/postgresql.conf
echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /etc/postgresql/9.5/main/pg_hba.conf
sudo service postgresql start

sudo -u postgres psql -c "CREATE ROLE root LOGIN UNENCRYPTED PASSWORD 'root' NOSUPERUSER INHERIT CREATEDB NOCREATEROLE NOREPLICATION;"

# copy config/*.example files, remove .example
rake db:create db:migrate

# start server
rails s -b 0.0.0.0 -p 8080
