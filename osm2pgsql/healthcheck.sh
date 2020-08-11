#!/bin/bash

if [ $(ps aux | grep loop.sh | wc -l) -ge 2 ]; then
	exit 0
else
	exit 1
fi
