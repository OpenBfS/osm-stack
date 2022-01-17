#! /usr/bin/env python3

import configparser
import psycopg2

service_name = "PostgreSQL Logical Replication"

def process_results_master(replications):
    status = 0
    status_text = "Replication status is unknown."
    for row in replications:
        this_status = 3
        if row[0] in ["startup", "catchup"]:
            this_status = 1
        elif row[0] in ["streaming", "backup"]:
            this_status = 0
        elif row[0] == "stopping":
            this_status = 2
        status = max(status, this_status)
    status_text = ""
    if status == 0:
        status_text = "Replication status of all followers is 'streaming' or 'backup'."
    elif status == 1:
        status_text = "Replication status of at least one follower is 'startup' or 'catchup'."
    elif status == 2:
        status_text = "Replication status of at least one follower is 'stopping'."
    elif status == 3:
        status_text = "Replication status of at least one follower is unknown."
    print('{} "{}" - {}'.format(status, service_name, status_text))
    exit(0)


# Read configuration
config = configparser.ConfigParser()
config.read("/etc/pg_replication_checker.conf")

publisher_dbname = config["publisher"]["dbname"]
publisher_host = config["publisher"]["host"]
publisher_port = config["publisher"]["port"]
publisher_user = config["publisher"]["user"]
subscriber_dbname = config["subscriber"]["dbname"]
is_master = (str(config["general"]["is_master"]) == "1")
max_diff_crit = int(config["thresholds"]["max_diff_critical"])
max_diff_warn = int(config["thresholds"]["max_diff_warn"])

# on master server
replications = []
current_wal_lsn = 0
connect_str = ""
if is_master:
    connect_str = "dbname=osm user=postgres"
else:
    connect_str = "dbname={} host={} user={} port={}".format(publisher_dbname, publisher_host, publisher_user, publisher_port)
with psycopg2.connect(connect_str) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT  inet_client_addr()")
        client_addr = cur.fetchone()[0]
        if is_master:
            cur.execute("SELECT state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication")
        else:
            cur.execute("SELECT state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication WHERE client_addr = %s", (client_addr,))
        replications = cur.fetchall()

if is_master:
    process_results_master(replications)
    exit(0)

# on follower
with psycopg2.connect("dbname={} user=postgres".format(subscriber_dbname)) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT pg_current_wal_lsn()")
        current_wal_lsn = cur.fetchone()[0]

status = "3" # unknown
status_text = "Replication lag is unknown."
offset = -1
if len(replications) > 0:
    offset = replications[0][3] - current_wal_lsn
if offset > max_diff_crit:
    status = "2"
    status_text = "Replication lag is critical ({} bytes).".format(offset)
elif offset > max_diff_warn:
    status = "1"
    status_text = "Replication lag is high ({} bytes).".format(offset)
elif offset >= 0:
    status = "0"
    status_text = "Replication lag is fine ({} bytes).".format(offset)
elif offset == -1:
    status = "2"
    status_text = "Replication does not exist."
values = {"value": offset, "warn": max_diff_warn, "crit": max_diff_crit, "min": 0, "max": ""}
values_str = "{value};{warn};{crit};{min};{max}".format(**values)

out_text = '{} "{}" replication_lag={} {}'.format(status, service_name, values_str, status_text)
print(out_text)
