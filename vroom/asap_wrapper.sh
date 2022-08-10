#! /usr/bin/env bash

set -euo pipefail

python3 /vroom-scripts/src/asap.py --pareto-front-more-solutions $@
#python3 /vroom-scripts/src/asap.py --pareto-front $@
