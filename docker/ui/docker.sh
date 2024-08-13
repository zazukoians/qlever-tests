#!/bin/sh

########################################################################
# This script simply outputs all commands that are provided            #
# It is used to ignore all calls to `docker` to avoid Docker in Docker #
########################################################################

echo "WARN: Something called a docker command:"
echo "WARN:     docker $@"
echo "WARN: The command was ignored"

exit 0
