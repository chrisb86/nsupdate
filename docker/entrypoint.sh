#! /bin/sh

echo "${SCHEDULE} sh nsupdate.sh" >> /etc/crontabs/root
crond -l 2 -f > /dev/stdout 2> /dev/stderr &