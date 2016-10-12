startDir=`pwd` #store this so we can come back to it later

function upsearch () { # this function looks for a file up the tree and gives up at root
    test / == "$PWD" && return || test -e "$1" && return || cd .. && upsearch "$1"
}

cd ${UMBatchMaster}
upsearch .dbConfig # look up the path for .dbConfig
candidatePath=$(pwd)/.dbConfig

if [ ! -f ${candidatePath} ]; then # if still not found, check other candidates
    if [ -f ${HOME}/.dbConfig ]; then
	candidatePath=${HOME}/.dbConfig
    elif [ -f /etc/.dbConfig ]; then
	candidatePath="/etc/.dbConfig"
    fi
fi

if [ -f ${candidatePath} ]; then
    export dbConfigPath=${candidatePath}
fi

cd ${startDir} # cd back to where we started
