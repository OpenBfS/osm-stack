FROM postgis/postgis:12-3.0

# procpcs provides pgrep which is required by check-mk
# libkakasi2, libutf8proc2 and icu-devtools are dependencies of postgresql-12-omsl10n
RUN apt-get update && apt-get upgrade -fy && apt-get install -y xinetd wait-for-it postgresql-plpython3-12 procps libkakasi2 libutf8proc2 icu-devtools
COPY thirdparty/check-mk-agent_1.5.0p24-1_all.deb /tmp/check-mk-agent.deb
RUN dpkg -i /tmp/check-mk-agent.deb && rm /tmp/check-mk-agent.deb

COPY thirdparty/mk_postgres /usr/lib/check_mk_agent/plugins/mk_postgres

COPY thirdparty/postgresql-12-osml10n_2.5.7_amd64.deb /tmp/postgresql-12-osml10n.deb
RUN dpkg -i /tmp/postgresql-12-osml10n.deb || true && apt-get install -f -y && rm /tmp/postgresql-12-osml10n.deb

RUN sed -i 's/#wal_level.*/wal_level = logical/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#max_wal_size.*/max_wal_size = 2GB/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#wal_compression = off.*/wal_compression = on/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#wal_recycle = on.*/wal_recycle = off/g' /usr/share/postgresql/postgresql.conf.sample

COPY replication.sh /docker-entrypoint-initdb.d/replication.sh

COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

ENTRYPOINT /entrypoint.sh
HEALTHCHECK CMD /healthcheck.sh
