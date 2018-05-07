[![Build Status](https://travis-ci.org/oasis4hedev/salsa.svg?branch=master)](https://travis-ci.org/oasis4hedev/salsa) [![Maintainability](https://api.codeclimate.com/v1/badges/db12ca4f669ebd3e0b0b/maintainability)](https://codeclimate.com/github/oasis4hedev/salsa/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/db12ca4f669ebd3e0b0b/test_coverage)](https://codeclimate.com/github/oasis4hedev/salsa/test_coverage)

Salsa
=====

Styled and Accessible Learning Service Agreements

Visit [syllabustool.com](http://syllabustool.com) for more information

Setting up a Ruby on Rails development environment (Mac OS X 10.10)
------------------------------------------

Install Homebrew

First, we need to install Homebrew. Homebrew allows us to install and compile software packages easily from source.

Homebrew comes with a very simple install script. When it asks you to install XCode CommandLine Tools, say yes.

Open Terminal and run the following command:

	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Installing Ruby


Now that we have Homebrew installed, we can use it to install Ruby.

We're going to use rbenv to install and manage our Ruby versions. https://github.com/sstephenson/rbenv

To do this, run the following commands in your Terminal:

	brew install rbenv ruby-build

	# Add rbenv to bash so that it loads every time you open a terminal
	echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
	source ~/.bash_profile

	# Install Ruby
	rbenv install 2.0.0-p481
	rbenv global 2.0.0-p481
	ruby -v

Configuring Git

We'll be using Git for our version control system so we're going to set it up to match our Github account. If you don't already have a Github account, register for free here: https://github.com/

Replace the example name and email address in the following steps with the ones you used for your Github account.

	git config --global color.ui true
	git config --global user.name "YOUR NAME"
	git config --global user.email "YOUR@EMAIL.com"
	ssh-keygen -t rsa -C "YOUR@EMAIL.com"

	#example
	git config --global color.ui true
	git config --global user.name "oasis4hedev"
	git config --global user.email "fakeuser@syllabustool.com"
	ssh-keygen -t rsa -C "fakeuser@syllabustool.com"

The next step is to take the newly generated SSH key and add it to your Github account. You want to copy and paste the output of the following command:

	cat ~/.ssh/id_rsa.pub

Login to GitHub. Click on the gear symbol (upper right-hand corner and select Settings. On the left-hand "Person settings" navigation, click on "SSH Keys". Click "Add SSH Key". Give the key a Title and Paste the public key into your GitHub account.

Once you've done this, you can check and see if it worked:

	ssh -T git@github.com

You should get a message like this:

	Hi User! You've successfully authenticated, but GitHub does not provide shell access.

Installing Rails


Installing Rails is as simple as running the following command in your Terminal:

	gem install rails -v 4.0.0

Rails is now installed, but in order for us to use the rails executable, we need to tell rbenv to see it:

	rbenv rehash

And now we can verify Rails is installed:

	rails -v

should return

	Rails 4.0.0

You can install PostgreSQL server and client from Homebrew:

	brew update
	brew doctor
	brew install postgresql

Once this command is finished, it gives you a couple commands to run. Follow the instructions and run them:

	# To have launchd start postgresql at login:
	ln -sfv /usr/local/opt/postgresql/*plist ~/Library/LaunchAgents

	# Then to load postgresql now:
	launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
	By default the postgresql user is your current OS X username with no password. For example, my OS X user is named chris so I can login to postgresql with that username.


Development Installation Notes OS X
-------------------------------------------

Requires Ruby 1.9+, Rails 4.0.0

(2.0.0-p481 works with the debugger gem, the latest didn't)

Clone repository

    git clone https://github.com/oasis4hedev/salsa.git
    cd salsa

Install postgres database using Homebrew

	brew update
	brew doctor
	brew install postgresql

Copy `config/database.yml.default` paste to `config/database.yml`, change as necessary.

Should look like:

	development:
	  adapter: postgresql
	  encoding: unicode
	  database: salsa_development
	  pool: 5
	  username: [by default OS X username]
	  password:
	  host: localhost

	test:
	  adapter: sqlite3
	  encoding: unicode
	  database: salsa_test
	  pool: 5
	  username: salsa
	  password:
	  host: localhost

	production:
	  adapter: postgresql
	  encoding: unicode
	  database: salsa_production
	  pool: 5
	  username: [by default OS X username]
	  password:

Copy `config/config.yml.default` paste to `config/config.yml`, change as necessary.

    bundle install
    bundle exec rake db:create db:migrate

To run the server, from the project root type:

    rails server

Goto [http://localhost:3000](http://localhost:3000) (ctrl + c shutsdown the server)

Production Notes
----------------

* OS: Ubuntu 12.04
* Web server: nginx, unicorn
* Database: PostgreSQL

Deploy through Capistrano

Copy `config/deploy/production.rb.default` paste to `config/deploy/production.rb`, change as necessary.

    cap production deploy
