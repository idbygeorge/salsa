xvfb-run -a cucumber RAILS_ENV=test $1
rm -rf /tmp/.X*-lock
