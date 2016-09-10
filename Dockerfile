# Dockerfile for oml2-server (with postgres backend)
# https://github.com/beakman/docker-oml2
#
# VERSION 0.1.0

FROM debian:7
MAINTAINER Francisco Salido <psalido@gmail.com>

# refresh soft
RUN apt-get update
RUN apt-get upgrade -y

# editor
RUN apt-get install -y vim

# install postgres
RUN apt-get install -y postgresql postgresql-contrib libpq-dev

# install oml2-server
RUN apt-get install -y ca-certificates wget
RUN wget http://download.opensuse.org/repositories/devel:tools:mytestbed:stable/Debian_7.0/Release.key
RUN apt-key add - < Release.key
RUN echo 'deb http://download.opensuse.org/repositories/devel:/tools:/mytestbed:/stable/Debian_7.0/ /' >> /etc/apt/sources.list.d/oml2.list
RUN apt-get update
RUN apt-get install -y oml2 oml2-generator oml2-apps

# supervisord
RUN mkdir -p /var/log/supervisor
RUN apt-get install -y supervisor

# config for auto start oml2-server/postgresql
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# start postgres & create db/user for oml2-server
RUN service postgresql start && \
    su postgres sh -c "createdb omldb" && \
    su postgres sh -c "createuser --no-createdb --encrypted --no-createrole --no-superuser tester" && \
    su postgres sh -c "psql -c \"ALTER USER tester WITH PASSWORD 'tester';\" " && \
    su postgres sh -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE omldb to tester;\""

# ports for ssh/sentry
EXPOSE 5432 3003

# run supervisord in foreground
CMD ["/usr/bin/supervisord", "--nodaemon"]