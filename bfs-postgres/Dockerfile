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
RUN sed -i 's/#wal_sender_timeout.*/wal_sender_timeout = 0/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#shared_buffers.*/shared_buffers = 16GB/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#work_mem.*/work_mem = 128MB/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#mainentenance_work_mem.*/mainentenance_work_mem = 256MB/g' /usr/share/postgresql/postgresql.conf.sample


#configure log_rotate
RUN sed -i "s/#log_destination.*/log_destination = 'stderr'/g" /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#logging_collector = off.*/logging_collector = on/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i "s/#log_directory =.*/log_directory = 'pg_log'/g" /usr/share/postgresql/postgresql.conf.sample
RUN sed -i "s/#log_filename =.*/log_filename = 'postgresql-%a.log'/g" /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#log_truncate_on_rotation = off.*/log_truncate_on_rotation = on/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i 's/#log_rotation_age =.*/log_rotation_age = 1d/g' /usr/share/postgresql/postgresql.conf.sample
RUN sed -i "s/#log_rotation_size = 0\nlog_line_prefix = '%m|%u%%%d: '\nlog_timezone = 'Europe/Berlin'/g" /usr/share/postgresql/postgresql.conf.sample

COPY replication.sh /docker-entrypoint-initdb.d/replication.sh

COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

ENTRYPOINT /entrypoint.sh
HEALTHCHECK CMD /healthcheck.sh
