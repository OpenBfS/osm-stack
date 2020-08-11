#!/bin/bash

set -e

psql -c "SELECT 1;" postgres postgres;
