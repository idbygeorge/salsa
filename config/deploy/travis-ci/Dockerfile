FROM ruby:2.4.0

# set the app directory var
ENV APP_HOME /home/apps/salsa
WORKDIR $APP_HOME

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs qt4-default cmake make xvfb
RUN gem install bundler

COPY salsa/Gemfile* ./
RUN bundle install
ADD . .
