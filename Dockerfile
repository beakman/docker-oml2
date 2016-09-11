# Dockerfile for oml2-server (with postgres backend)
# https://github.com/beakman/docker-oml2
#
# VERSION 0.1.0
#
# Build: docker build -t fsalido/oml2-server .
# Run: docker run -ti -p 5432:5432 -p 3003:3003 fsalido/oml2-server

FROM debian:7
MAINTAINER Francisco Salido <psalido@gmail.com>

# refresh soft
RUN apt-get update
RUN apt-get upgrade -y

# editor
RUN apt-get install -y vim

# wget and certificates manager
RUN apt-get install -y ca-certificates wget

# install postgres 9.3
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
RUN wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key add ACCC4CF8.asc
RUN apt-get update
RUN apt-get install -y postgresql-9.3

# install oml2-server
RUN wget http://download.opensuse.org/repositories/devel:tools:mytestbed:stable/Debian_7.0/Release.key
RUN apt-key add - < Release.key
RUN echo 'deb http://download.opensuse.org/repositories/devel:/tools:/mytestbed:/stable/Debian_7.0/ /' >> /etc/apt/sources.list.d/oml2.list
RUN apt-get update
RUN apt-get install -y oml2 oml2-generator oml2-apps
RUN echo 'OPTS="$OPTS --backend postgresql --pg-host=localhost --pg-port=5432 --pg-user=oml --pg-pass=tester"' >> /etc/default/oml2-server

# supervisord
RUN mkdir -p /var/log/supervisor
RUN apt-get install -y supervisor

# config for auto start oml2-server/postgresql
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# ADD conf/start-services.sh /start-services.sh

# configure postgresql
RUN echo "host all all  0.0.0.0/0 md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# start postgres & create db/user for oml2-server
RUN service postgresql start && \
    su postgres sh -c "createdb omldb" && \
    su postgres sh -c "createuser --no-superuser --createdb --no-createrole oml" && \
    su postgres sh -c "psql -c \"ALTER USER oml WITH PASSWORD 'tester';\" "	

# test data
# RUN service oml2-server start && \
# 	oml2-generator --amplitude 1 --frequency 1000 --samples 10 --sample-interval .1 --oml-id localservertest --oml-domain installtest --oml-collect localhost

# ports for ssh/oml2
EXPOSE 5432 3003

# run supervisord in foreground
CMD ["/usr/bin/supervisord", "--nodaemon"]
# CMD ["bash", "/start-services.sh", "--nodaemon"]