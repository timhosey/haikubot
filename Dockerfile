FROM ruby:alpine
ENTRYPOINT ["ruby", "hbot.rb"]

WORKDIR /app

ADD Gemfile /app/
RUN apt install imagemagick
RUN bundle install -j 8

ADD . /app