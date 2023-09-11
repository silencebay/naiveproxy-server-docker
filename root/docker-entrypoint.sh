#!/bin/bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

ARGS=("${@}")

if [ ! -z "$PREFER_IPV4" ]; then
    grep -qE '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' | tee -a /etc/gai.conf
elif [ ! -z "$PREFER_IPV6" ]; then
    grep -qE '^[ ]*label[ ]*2002::/16[ ]*2' /etc/gai.conf || echo 'label 2002::/16   2' | tee -a /etc/gai.conf
fi

# Now execute the command passed as arguments. If running as process ID
# 1, we want to do that as a sub process to the 'tini' process, which
# will perform reaping of zombie processes for us.

if [ $$ = 1 ]; then
    TINI=( "/tini" "--" )
    ARGS=( ${TINI[@]} ${ARGS[@]} )
fi

exec setpriv --reuid=naive --regid=naive --init-groups ${ARGS[@]}