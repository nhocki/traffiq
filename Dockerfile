FROM ruby:2.2.2
MAINTAINER Sergio Botero <sergio@ride.com>

CMD mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD . /usr/src/app
RUN bundle install

CMD ["rake", "test"]
