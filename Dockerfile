FROM phusion/baseimage:0.9.11
MAINTAINER needo <needo@superhero.org>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN apt-get update -q

# Install plexWatch Dependencies
RUN apt-get install -qy libwww-perl libxml-simple-perl libtime-duration-perl libtime-modules-perl libdbd-sqlite3-perl perl-doc libjson-perl libfile-readbackwards-perl

# Add our crontab file
ADD crons.conf /root/crons.conf

# Use the crontab file
RUN crontab /root/crons.conf

# Start cron
RUN cron

# Install plexWebWatch Dependencies
RUN apt-get install -qy apache2 libapache2-mod-php5 wget php5-sqlite

# Enable PHP
RUN a2enmod php5

# Delete the annoying default index.html page
RUN rm -f /var/www/html/index.html

# Update apache configuration with this one
ADD apache-config.conf /etc/apache2/sites-available/000-default.conf
ADD ports.conf /etc/apache2/ports.conf

# The plexWatch directory. Where the binary, config, and database is
VOLUME /plexWatch

# Install plexWebWatch
# RUN mkdir -p /var/www/html

# Set config.php to under plexWatch
RUN ln -s /plexWatch /var/www/html

# Manually set the apache environment variables in order to get apache to work immediately.
RUN echo www-data > /etc/container_environment/APACHE_RUN_USER
RUN echo www-data > /etc/container_environment/APACHE_RUN_GROUP
RUN echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR
RUN echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR
RUN echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE

EXPOSE 8080

# Plex Logfile directory for IP addresses
VOLUME /log

# Add edge.sh to execute during container startup
#RUN mkdir -p /etc/my_init.d
#ADD edge.sh /etc/my_init.d/edge.sh
#RUN chmod +x /etc/my_init.d/edge.sh

# Add apache to runit
RUN mkdir /etc/service/apache
ADD apache.sh /etc/service/apache/run
RUN chmod +x /etc/service/apache/run
