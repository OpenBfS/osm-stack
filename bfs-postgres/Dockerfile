FROM postgis/postgis:13-3.1

# procpcs provides pgrep which is required by check-mk
# libkakasi2, libutf8proc2 and icu-devtools are dependencies of postgresql-12-omsl10n
RUN apt-get update && apt-get upgrade -fy && apt-get install -y xinetd wait-for-it postgresql-plpython3-12 procps libkakasi2 libutf8proc2 icu-devtools python3 python3-psycopg2
COPY thirdparty/check-mk-agent_1.5.0p24-1_all.deb /tmp/check-mk-agent.deb
RUN dpkg -i /tmp/check-mk-agent.deb && rm /tmp/check-mk-agent.deb

COPY thirdparty/mk_postgres /usr/lib/check_mk_agent/plugins/mk_postgres
COPY mk_postgres_replication.py mk_valid_geometries.py /usr/lib/check_mk_agent/local/
RUN chmod a+x /usr/lib/check_mk_agent/local/*.py

COPY write_pg_replication_checker_conf.sh /
RUN chmod a+x /write_pg_replication_checker_conf.sh

COPY thirdparty/postgresql-13-osml10n_2.5.8_amd64.deb /tmp/postgresql-13-osml10n_2.5.8_amd64.deb
RUN dpkg -i /tmp/postgresql-13-osml10n_2.5.8_amd64.deb || true && apt-get install -f -y && rm /tmp/postgresql-13-osml10n_2.5.8_amd64.deb

COPY update_postgresql_conf.sh /
RUN chmod a+x /update_postgresql_conf.sh && \
    POSTGRES_SHARED_BUFFERS=1GB /update_postgresql_conf.sh /usr/share/postgresql/postgresql.conf.sample

##configure log_rotate
#RUN sed -i "s/#log_destination.*/log_destination = 'stderr'/g" /usr/share/postgresql/postgresql.conf.sample
#RUN sed -i 's/#logging_collector = off.*/logging_collector = on/g' /usr/share/postgresql/postgresql.conf.sample
#RUN sed -i "s/#log_directory =.*/log_directory = 'pg_log'/g" /usr/share/postgresql/postgresql.conf.sample
#RUN sed -i "s/#log_filename =.*/log_filename = 'postgresql-%a.log'/g" /usr/share/postgresql/postgresql.conf.sample
#RUN sed -i 's/#log_truncate_on_rotation = off.*/log_truncate_on_rotation = on/g' /usr/share/postgresql/postgresql.conf.sample
#RUN sed -i 's/#log_rotation_age =.*/log_rotation_age = 1d/g' /usr/share/postgresql/postgresql.conf.sample
#RUN sed -i "s/#log_rotation_size = 0\nlog_line_prefix = '%m|%u%%%d: '\nlog_timezone = 'Europe/Berlin'/g" /usr/share/postgresql/postgresql.conf.sample

COPY replication.sh /docker-entrypoint-initdb.d/replication.sh

COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

ENTRYPOINT /entrypoint.sh
HEALTHCHECK CMD /healthcheck.sh
