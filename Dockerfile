# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-ruby21:0.9.16

RUN apt-get update

ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features. Uncomment the features you want:
#
#   Build system and git.
RUN /build/utilities.sh
RUN /build/ruby2.1.sh

#   Common development headers necessary for many Ruby gems,
#   e.g. libxml for Nokogiri.
RUN /build/devheaders.sh


# cache install bundle
ADD ./Gemfile /tmp/Gemfile
ADD ./Gemfile.lock /tmp/Gemfile.lock
WORKDIR /tmp
RUN bundle install

# ...put your own build instructions here...
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default
ADD config/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf

ADD config/docker/app-env.conf /etc/nginx/main.d/app-env.conf


RUN mkdir /home/app/webapp
ADD ./ home/app/webapp/
WORKDIR /home/app/webapp

# add worker start script
RUN mkdir /etc/service/sidekiq
ADD config/docker/start_worker.sh /etc/service/sidekiq/run
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
