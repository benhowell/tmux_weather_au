#!/bin/bash


#------------------------------------------------------------------------------#
#                        Generic utility functions                             #
#------------------------------------------------------------------------------#


# Reads line number from file
# Args: line_number file
read_line() {
    echo $(sed -n "$1p" "$2")
}


# Inserts content at line number in file (prepends to existing content in line)
# Args: line_number string file
insert_line() {
    sed -i "$1i "$2"" $3
}


# Replaces content at line number in file
# Args: line_number string file
replace_line() {
    #sed -i "$1"'s/.*/'"$2"'/' $3
    #echo $(printf '%ss/.*/%s/' $1 $2)
    sed -i $(printf '%ss/.*/%s/' $1 $2) $3
}


# Prints file
# Args: file
print_file() {
    while IFS= read -r line; do echo "$line"; done < $1
}


# Endpoint file cacher
# if file cached, return it
# else curl end-point, cache file, return it
# Args: endpoint
cache_endpoint() {
    CACHE="$1_C"
    RES="${!CACHE}"
    if [ ${RES:+1} ]; then
        echo "$RES"
    else
        printf -v "$CACHE" "%s" "$(curl -s ${!1})"
        echo "${!CACHE}"
    fi
}


# checks if n1 is less than n2 
# NOTE: 0=true, 1=false
# Args: n1 n2
is_less_than() {
    if [ "$(($1))" -lt "$(($2))" ]; then return 0; else return 1; fi
}


# Args: string
is_int() {
    re='^[0-9]+$'
    if [[ $1 =~ $re ]] ; then return 0; else return 1; fi
}


# Args: string
dehyphen() {
    echo -e "$1" | sed '/^-/d'
}


# Args: string
despace() {
    echo -e "$1" | tr -d '[:space:]'
}


# Args: string
to_lower() {
    echo -e "$1" | tr '[:upper:]' '[:lower:]'
}


# Args: string
to_upper() {
    echo -e "$1" | tr '[:lower:]' '[:upper:]'
}


# save/persist dict (associative array) to file
# Usage: 
# - save dict to file: save_dict d >/path/to/file
# - append dict to file: save_dict d >>/path/to/file
# Args: dict
save_dict(){ 
    declare -p $1; 
}


# read dict (associative array) from file
# Usage: 
# - load dict from file: load_dict d </path/to/file
# - load dict from string: load_dict d <<< $string
# Args: dict_var
load_dict(){
    local l; read -r l; eval "${l/-A*=(/-gA $1=(}"; 
}


# Args: key_value
# Returns: key
dict_key() {
    echo $(echo "$1" | cut -d "=" -f 1)    
}


# Args: key_value
# Returns: value
dict_val() {
    echo $(echo $1 | cut -d "=" -f 2)
}


# NOTE: alias
# Args: dict_name key value
dict_ref_insert() {
    array_ref_insert "$@"
}


# Args: dict_name key value
dict_ref_append() {
    #FIXME: and test
    #local -n dict=$1
    #dict+=([$2]=$3)
    
    local ref=$1
    declare -n dict="$ref"
    dict+=([$2]=$3)
}


# Applies referenced function to each array element
# Args: target_value function_ref array
array_has_value() {
    local e m="$1" fn="$2"
    shift;shift
    for e; do [[ "$($fn "$e")" == "$m" ]] && return 0; done
    return 1
}


# Args: array_ref
print_array_ref() {
    local ref=$1
    declare -n arr="$ref"
    for x in "${!arr[@]}"; do 
        printf "[%s]=%s\n" "$x" "${arr[$x]}" ; done
}


# Args: array
print_array() {
    local -n a=$1
    for x in "${!a[@]}"; do 
        printf "[%s]=%s\n" "$x" "${a[$x]}" ; done
}


#TODO: add separator arg
# creates localised array from file using newline as separator
# Args: array_name file_path
array_from_file () {
    local -n a=$1
    mapfile -t a < "${2}"
}


# creates localised array by splitting string on sep
# Args: array_name string separator
split_string () {
    local -n a=$1
    readarray -td $3 a <<<$2
}


# Args: array_name index value
array_ref_insert() {
    local ref=$1; 
    declare -n arr="$ref"; 
    arr[$2]="$3"
}


# Args: array_name value
array_ref_append() {
    local ref=$1
    declare -n arr="$ref"
    arr+=("$2")
}
