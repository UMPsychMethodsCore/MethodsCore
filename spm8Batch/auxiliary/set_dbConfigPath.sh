candidatePath = ${somevar}/.dbConfig # optionally go thru priority list of locations
if [-f ${candidatePath}]; then
    export dbConfigPath=${somevar}/.dbConfig
fi
