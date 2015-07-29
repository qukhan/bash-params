#!/bin/bash

# Call this script : example.sh --flag --param 42

source bash-params.sh

param-def flag
param-def param

# redefining the flag option so that it doesn't consume a parameter
parameters-flag () {
    FLAG="1"
    return 0;
}

param-parse "$@"

echo "--param: "${PARAM}
echo "--flag : "${FLAG}
