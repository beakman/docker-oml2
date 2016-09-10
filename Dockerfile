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
RUN echo 'OPTS="$OPTS --backend postgresql --pg-host=localhost --pg-port=5432 --pg-user=oml --pg-pass=tester"' >> /etc/default/oml2-server

# supervisord
# RUN mkdir -p /var/log/supervisor
# RUN apt-get install -y supervisor

# config for auto start oml2-server/postgresql
#ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD conf/start-services.sh /start-services.sh

# configure postgresql
RUN echo "host all all  0.0.0.0/0 md5" >> /etc/postgresql/9.1/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.1/main/postgresql.conf

# start postgres & create db/user for oml2-server
RUN service postgresql start && \
    su postgres sh -c "createdb omldb" && \
    su postgres sh -c "createuser --no-superuser --createdb --no-createrole oml" && \
    su postgres sh -c "psql -c \"ALTER USER oml WITH PASSWORD 'tester';\" "

# ports for ssh/oml2
EXPOSE 5432 3003

# run supervisord in foreground
#CMD ["/usr/bin/supervisord", "--nodaemon"]
CMD ["bash", "/start-services.sh", "--nodaemon"]