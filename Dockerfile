# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-ruby21:0.9.11
# Or, instead of the 'full' variant, use one of these:
#FROM phusion/passenger-ruby19:<VERSION>
#FROM phusion/passenger-ruby20:<VERSION>
#FROM phusion/passenger-ruby21:<VERSION>
#FROM phusion/passenger-nodejs:<VERSION>
#FROM phusion/passenger-customizable:<VERSION>

RUN apt-get update

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features. Uncomment the features you want:
#
#   Build system and git.
RUN /build/utilities.sh
#   Ruby support.
#RUN /build/ruby1.9.sh
#RUN /build/ruby2.0.sh
RUN /build/ruby2.1.sh
#   Common development headers necessary for many Ruby gems,
#   e.g. libxml for Nokogiri.
RUN /build/devheaders.sh
#   Python support.
#RUN /build/python.sh
#   Node.js and Meteor support.
#RUN /build/nodejs.sh

# ...put your own build instructions here...
RUN rm -f /etc/service/nginx/down
ADD config/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mkdir /home/app/webapp
ADD ./ home/app/webapp

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*