#! /usr/bin/env python3

import argparse
import enum
import json
import logging
import os
import os.path
import shutil
import subprocess
import time

MAX_TRY = 5
SLEEP_AFTER_FAIL = 60


class DataSyncStatus(enum.Enum):
    UNKNOWN = 0
    UPDATED = 1
    TRY_LATER = 2
    FAILURE = 3


class UpdateResult:
    def __init__(self, status=DataSyncStatus.UNKNOWN, dest_dir=None):
        self.status = status
        self.dest_dir = dest_dir
        self.last_update = 0
        self.old_dir = None


class SSHException(Exception):
    def __init__(self, *args, **kwargs):
        Exception.__init__(self, *args, **kwargs)


def remote_all_in_dir(directory):
    """Remove all files and directories in the provided directory."""
    items = os.listdir(directory)
    logging.info("Removing all files in {}".format(directory))
    for item in items:
        shutil.rmtree(os.path.join(directory, item))


def try_command(cmd_args, log_msg):
    """Try to execute a command MAX_TRY times, sleep SLEEP_AFTER_FAIL seconds after each failed attempt and return the standard output of that command."""
    i = 0
    while True:
        i += 1
        logging.info(log_msg)
        result = subprocess.run(cmd_args, capture_output=True)
        result_stdout = result.stdout
        logging.debug(result.stderr.decode("utf-8"))
        args_str = '"{}"'.format('" "'.join(cmd_args))
        if result.returncode == 0:
            return result_stdout
        elif i < MAX_TRY:
            logging.warning("FAILED with exit code {}: {}. Next attempt in {} seconds.\nCommand: {}\nOutput on STDERR: {}".format(result.returncode, log_msg, SLEEP_AFTER_FAIL, args_str, result.stderr.decode("utf-8")))
            time.sleep(SLEEP_AFTER_FAIL)
            continue
        logging.error("FAILED with exit code {}: {}. Output on STDERR: {}".format(result.returncode, log_msg, result.stderr.decode("utf-8")))
        raise SSHException("Failed because command returned return code {} for: {}".format(result.returncode, args_str))


def make_ssh_command(arguments):
    return ["ssh", "-i", args.identity_file, "-p", str(arguments.port), "-o", "StrictHostKeyChecking=no"]


def get_destination_dir(data_parent):
    secs = str(int(time.time()))
    return os.path.join(data_parent, secs)


def ensure_trailing_slash(directory):
    if not directory.endswith("/"):
        return "{}/".format(directory)


def get_latest_dir(parent_dir):
    return os.path.join(parent_dir, "latest")


def fetch_data(arguments, **kwargs):
    init = kwargs.get("init", False)
    dest_dir = get_destination_dir(args.data_production)
    last_update = str(kwargs.get("last_update", 0))
    # Get latest directory and lock it
    ssh_command_base = make_ssh_command(arguments)
    user_at_host = "{}@{}".format(arguments.user, arguments.hostname)
    # Lock directory on remote host, get its path
    status = UpdateResult()
    remote_dir = None
    lockfile_path = None
    try:
        lock_data = try_command(ssh_command_base + [user_at_host, args.latest_command, args.remote_directory, last_update], "Locking directory on remote host. Last local update is {}".format(last_update))
        if not lock_data:
            raise SSHException("Failed to aquire lock, got empty response.")
        locking_result = json.loads(lock_data)
        if not locking_result.get("update_available", False):
            logging.info("There is no new data available on the remote host.")
            return UpdateResult(DataSyncStatus.TRY_LATER)
        lockfile_path = locking_result.get("lockfile")
        last_update = locking_result.get("last_update", 0)
        if not lockfile_path:
            logging.info("Did not receive a valid path to load data from. It seems that there is no need to update data.")
            return UpdateResult(DataSyncStatus.FAILURE)
        remote_dir = ensure_trailing_slash(os.path.dirname(lockfile_path))
        # Copying data from production to destination directory to prepare update
        latest_dir = get_latest_dir(args.data_production)
        if not init:
            logging.info("Copying data from {} to {} to speed up rsync".format(latest_dir, dest_dir))
            # shutil.copytree requires destination not to exist
            if os.path.isdir(dest_dir):
                shutil.rmtree(dest_dir)
            shutil.copytree(latest_dir, dest_dir, symlinks=True)
        elif not os.path.isdir(dest_dir):
            logging.info("Creating {}".format(dest_dir))
            # If dest_dir does exist already, raise an error and try again later.
            os.mkdir(dest_dir)
        # Loading data using rsync
        try_command(["rsync", "-a", "--delete", "-e", "ssh -o StrictHostKeyChecking=no -i {} -p {}".format(args.identity_file, args.port), "{}:{}".format(user_at_host, remote_dir), dest_dir], "Copying data from remote host ({}:{} -> {})".format(user_at_host, remote_dir, dest_dir))
        if init:
            logging.info("Creating local symlink {}/latest pointing to {}".format(args.data_production, dest_dir))
            os.symlink(dest_dir, latest_dir)
        else:
            logging.info("Updating local symlink {}/latest to make it point to {}".format(args.data_production, dest_dir))
            status.old_dir = os.path.realpath(latest_dir)
        status.status = DataSyncStatus.UPDATED
        status.dest_dir = dest_dir
        status.last_update = last_update
    except SSHException:
        logging.exception("Failed to execute command")
        status.status = DataSyncStatus.FAILURE
    except:
        logging.exception("An unknown exception was raised by a command requiring access to the remote host.")
        status.status = DataSyncStatus.FAILURE
    finally:
        # Unlocking
        try:
            if lockfile_path:
                try_command(ssh_command_base + [user_at_host, args.unlock_command, lockfile_path], "Unlocking directory on remote host")
        except SSHException:
            logging.exception("Failed to unlock {} on the remote host".format(remote_dir))
            status.status = DataSyncStatus.FAILURE
        except:
            logging.exception("An unknown exception was raised during unlocking {} on the remote host".format(remote_dir))
            status.status = DataSyncStatus.FAILURE
    if status == DataSyncStatus.FAILURE:
        logging.info("Removing destination directory because update failed.")
        if os.path.isdir(dest_dir):
            shutil.rmtree(dest_dir)
    return status


def start_service(command_args, shell=False):
    """Start the service and return a subprocess.Popen instance."""
    if type(command_args) is list:
        logging.info("Starting the service with \"{}\"".format("\" \"".join(command_args)))
    else:
        logging.info("Starting the service with \"{}\"".format(command_args))
    proc = subprocess.Popen(command_args, shell=shell)
    return proc


def restart_service(proc, args, update_result):
    new_data_dir = update_result.dest_dir
    cmd_args = proc.args
    stop_cmd = args.stop_command
    start_service(stop_cmd, True)
    if update_result.old_dir:
        logging.info("Delete {} and create symlink {} -> {}".format(update_result.old_dir, new_data_dir, args.data_production))
        shutil.rmtree(update_result.old_dir)
        latest_dir = get_latest_dir(args.data_production)
        if os.path.islink(latest_dir):
            os.remove(latest_dir)
        os.symlink(new_data_dir, latest_dir)
    return start_service(cmd_args)


def ensure_running(proc):
    if proc.returncode is not None:
        logging.warning("Service terminated permaturely")
        start_service(proc.args)


parser = argparse.ArgumentParser(description="Run a service using static data on disk, update its data and restart it after the update")
parser.add_argument("-l", "--log-level", type=str, default="INFO", help="Log level")
parser.add_argument("-I", "--interval", type=int, default=3600*24, help="Update interval in seconds")
parser.add_argument("-d", "--data-production", type=str, required=True, help="Path to the directory for production data on this host. The argument should point to the parent directory where the copies of the dataset are located.")
parser.add_argument("-H", "--hostname", type=str, required=True, help="Hostname of the remote host to load data from")
parser.add_argument("-u", "--user", type=str, required=True, help="User name at the remote host to load data from")
parser.add_argument("-i", "--identity-file", type=str, required=True, help="Path to SSH private key file")
parser.add_argument("-p", "--port", type=int, default=22, help="SSH port")
parser.add_argument("-L", "--latest-command", type=str, required=True, help="Command to execute on remote host to get the latest directory and lock it")
parser.add_argument("-U", "--unlock-command", type=str, required=True, help="Command to execute on remote host to release a lock on a directory. The path to the lockfile will be appended to the list of its arguments.")
parser.add_argument("-r", "--remote-directory", type=str, required=True, help="Parent directory of the data directories on the remtoe host")
parser.add_argument("-s", "--stop_command", type=str, required=True, help="Command to stop service")
parser.add_argument("service_command", nargs="+", help="Command of the service to be started")
args = parser.parse_args()


# log level
numeric_log_level = getattr(logging, args.log_level.upper())
if not isinstance(numeric_log_level, int):
    raise ValueError("Invalid log level {}".format(args.log_level.upper()))
logging.basicConfig(level=numeric_log_level)

# check if necessary directory exists
if not os.path.isdir(args.data_production):
    logging.critical("ERROR: {} is not a directory.".format(args.data_production))
    exit(1)

if not os.path.isfile(args.identity_file):
    logging.critical("ERROR: Identity file cannot be accessed.")
    exit(1)

last_update = 0
prod_content = os.listdir(args.data_production)
if len(prod_content) == 0:
    logging.info("Production directory is empty, fetching data first.")
    last_update = time.time()
    update_result = UpdateResult()
    while update_result.status != DataSyncStatus.UPDATED:
        logging.info("Trying initial data update. This will fail as long as the other containers are not ready.")
        update_result = fetch_data(args, init=True)
        if update_result.status != DataSyncStatus.UPDATED:
            logging.info("Update failed, trying again in 60 seconds.")
            time.sleep(60)
service = start_service(args.service_command)
while True:
    now = time.time()
    if now - last_update < args.interval:
        ensure_running(service)
        time.sleep(2)
        continue
    result = fetch_data(args, last_update=last_update, init=False)
    if result.status == DataSyncStatus.UPDATED:
        last_update = now
        service = restart_service(service, args, result)
