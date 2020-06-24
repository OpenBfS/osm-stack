#! /usr/bin/env python3

import argparse
import json
import os
import os.path
import random
import sys


def write_json(doc):
    sys.stdout.write(json.dumps(doc))
    sys.stdout.write("\n")


def lock_dir(directory):
    # Find name for a lockfile which has not been used yet.
    while True:
        number = random.randint(1, 1000000)
        filename = "{}.lock".format(number)
        lockfile_path = os.path.join(directory, filename)
        if not os.path.isfile(lockfile_path):
            open(lockfile_path, "a").close()
            return lockfile_path


parser = argparse.ArgumentParser(description="Get latest subdirectory in a directory of data directories")
parser.add_argument("parent_directory", type=str, help="Parent directory of the individual data directories")
parser.add_argument("last_update", type=float, help="Time in seconds since the epoch that was assigned to the last update")
args = parser.parse_args()

parent_dir = args.parent_directory
last_update = int(args.last_update)
dir_content = os.listdir(parent_dir)
dir_content = [d for d in dir_content if d.isnumeric()]
dir_content.sort(key=lambda e: int(e), reverse=True)

for d in dir_content:
    dd = os.path.join(parent_dir, d)
    if os.path.isfile(os.path.join(dd, "complete")):
        update_available = (last_update < int(d))
        if update_available:
            lockfile = lock_dir(dd)
        else:
            lockfile = None
        write_json({"update_available": update_available, "lockfile": lockfile, "last_update": int(d)})
        exit(0)
# Nothing found
write_json({"update_available": False, "lockfile": None, "last_update": None})
