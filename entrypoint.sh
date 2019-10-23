#!/bin/sh -e

# check profided config file for db path, otherwise set system default
DATABASE="/tmp/minitwit.db"
if [ ! -z "${MINITWIT_SETTINGS}" ] ; then
    . ${MINITWIT_SETTINGS}
fi

# if db is not there, init it
if [ ! -f "${DATABASE}" ] ; then
    echo "Attempting to auto init database located at: ${DATABASE}"
    flask initdb
fi

exec /usr/bin/dumb-init -- $*