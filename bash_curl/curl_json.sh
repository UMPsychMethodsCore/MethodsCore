#!/bin/bash

FILE=$1
TARGET=$2

curl -i -X POST $TARGET -H "Content-Type: application/json" --data-binary "@${FILE}"
