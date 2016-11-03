if [ -f ${dbConfigPath} ]; then # only if dbConfigFilePath exists (and is defined)
    set -a
    source ${dbConfigPath}
    set +a
fi
