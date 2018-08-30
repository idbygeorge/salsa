#!/bin/bash
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

if [ ! -f $SCRIPTPATH/config/secrets.yml ]; then
  echo -e "\nGenerating a secrets.yml file"

  # Random Keys
  KEY_DEV=`docker-compose run salsa rake secret`
  KEY_TEST=`docker-compose run salsa rake secret`

  # Generate the file
  cat > $SCRIPTPATH/config/secrets.yml <<EOL
# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure the secrets in this file are kept private
# if you're sharing your code publicly.

development:
  secret_key_base: ${KEY_DEV}

test:
  secret_key_base: ${KEY_TEST}

# Do not keep production secrets in the repository,
# instead read values from the environment.
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
EOL
fi

mkdir $SCRIPTPATH/tmp/ssl -p

if [ ! -f $SCRIPTPATH/tmp/ssl/localhost.crt ] || [ ! -f $SCRIPTPATH/tmp/ssl/localhost.key ]; then
  echo -e "\nGenerating ssl new cert and key"
  openssl req -new -newkey rsa:2048 -sha1 -days 365 -nodes -x509 -keyout $SCRIPTPATH/tmp/ssl/localhost.key -out $SCRIPTPATH/tmp/ssl/localhost.crt
fi
