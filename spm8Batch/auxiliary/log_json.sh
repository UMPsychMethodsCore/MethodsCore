#!/bin/bash

FILE=$1
RegType=$2

theCommand=`which $0`
thisDir=`dirname $theCommand`

. ${thisDir}/parse_dbConfig.sh # parse the dbConfig

if [ -z "${dbKey}" ] || [ -z "{dbTarget}" ]; then # fall down if important vars not set
    return 0
fi


case ${RegType} in
    op)
	curl -H "Content-Type: application/json" -H "Authorization: ${dbKey}" -X POST -d@${FILE} ${dbTarget}/register_op.php
	;;

    session)
	curl -H "Content-Type: application/json" -H "Authorization: ${dbKey}" -X POST -d@${FILE} ${dbTarget}/register_session.php
	;;
esac
