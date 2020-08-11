#! /usr/bin/env python3

import argparse
import os

parser = argparse.ArgumentParser(description="Release a lock on a data directory")
parser.add_argument("lockfile_path", type=str, help="Path to the lockfile")
args = parser.parse_args()
os.remove(args.lockfile_path)
