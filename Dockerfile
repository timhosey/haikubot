FROM ruby:latest
ENTRYPOINT ["ruby", "hbot.rb"]

WORKDIR /app

ADD Gemfile Gemfile.lock /app/
RUN apt install imagemagick
RUN bundle install -j 8

ADD . /app