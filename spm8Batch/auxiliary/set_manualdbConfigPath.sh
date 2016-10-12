
if [! -f $1 ]; then
    echo "dbConfig file not found at custom path ($1). Aborting."
    . ${thisDir}/auxiliary/exit_w_removal
else
    export dbConfigPath=$1
fi
