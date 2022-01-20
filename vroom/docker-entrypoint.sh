#! /usr/bin/env bash

set -euo pipefail

set-vroom-express-config

cd /vroom-express && VROOM_LOG=/var/lib/vroom-express/tmp VROOM_ROUTER=ors npm start
