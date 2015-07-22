# This file is not meant be executed alone, use it from an other script.

# Parameter function list (indexed by flag)
declare -A parameters
# Parameter description list (indexed by flag list)
declare -A parametershelp

# Defines standard parameters
#
# This function defines does two main actions :
#  * It defines a variable following the `main-flag`, removing any dash and
#    transforming all letters to upper case. For intance : `main-flag` will
#    give a variable called `MAINFLAG`.
#  * For each flag (main and optionnal), it defines a function called 
#    `parameters-FLAGNAME` and adds it the `parameters` array with the key
#    `--flag` (or `-f` if the flag is one letter long). This function sets
#    the `MAINFLAG` variable to its first argument value.
#
# The parsing function can be (re)defined to get a new behaviour. It's return
# value must be the number of arguments parsed (0 for a flag, 1 or more for
# options)
#
# usage : param-def main-flag [opt-flags] [ :- default value] [:! help description] 
# 
# If given, the default value must precede the help description
param-def () {
    # Create variable name from first arg
    local PARAM=$(echo $1 | sed 's/-//g' | tr '[:lower:]' '[:upper:]');
    # Get all the flags (until a :- or a :! argument)
    local FLAGS=$(echo "$*" | awk -F ":!" '{print $1}' | awk -F ":-" '{print $1}' \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    # Get the default value (between :- and :!)
    local DEFAULT=$(echo "$*" | awk -F ":!" '{print $1}'  | awk -F ":-" '{print $2}' \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    # Get the help description (after :!)
    local HELP=$(echo "$*" | awk -F ":!" '{print $2}' \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Set param to default value
    if ! [ -z "${DEFAULT}" ]; then
        eval ${PARAM}="$(echo '$DEFAULT')"
    fi

    local FLAG_LIST=""

    # Create parse function and insert it in the function list 
    for FLAG in ${FLAGS}; do
        eval "parameters-$FLAG () { export "$PARAM"=\$1; return 1; };"
        local CUR_FLAG=$( [ ${#FLAG} -eq 1 ] && echo "-" || echo "--" )"$FLAG"
        parameters["${CUR_FLAG}"]="parameters-$FLAG"
        FLAG_LIST="${FLAG_LIST:+$FLAG_LIST }${CUR_FLAG}"
    done;
    # Insert help in the help messages list
    parametershelp["${FLAG_LIST}"]="${HELP:-No description available}"
}


# Parse script arguments
# Call this after setting all parameters and custom paramter parsing functions
param-parse () {
    while [ "$#" -gt 0 ]; do
        ARG="$1"
        shift
        if [ -z "${parameters["$ARG"]}" ]; then
            echo "Unknown parameter '$ARG'" >&2
            exit -1;
        else
            "${parameters["$ARG"]}" "$@";
            RETVAL="$?"

            shift $RETVAL
        fi
    done;    
}


# Help parameter
# This is an example of how to change the action triggered by a parameter
param-def help :! "Show help message"
parameters-help() {
    echo -e "USAGE:\n\t$0 [OPTIONS]"
    echo "OPTIONS:"

    local sortedflags
    readarray -t sortedflags < <(for j in "${!parametershelp[@]}"; do echo $j; done | sort)

    for flag in "${sortedflags[@]}"; do
        echo -e "\t" ${flag} ""
        echo -e "\t\t"${parametershelp["$flag"]}
    done

    exit 0;
}

# Hidden arg for bash completion
# This is an example of how to create a hidden parameter
parameters-completion () {
    echo -n "-W '"
    for flag in "${!parametershelp[@]}"; do
        echo -n "${flag}" | cut -d\  -f 1;
    done
    echo "'"
    exit -1;
}
parameters["--completion"]=parameters-completion

