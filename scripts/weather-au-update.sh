#!/bin/bash


#------------------------------------------------------------------------------#
# Outputs BOM data to give a basic tmux status line weather report. BOM OBS    #
# data is updated every 10 minutes.                                            #
#                                                                              #
# docs: http://www.bom.gov.au/catalogue/anon-ftp.shtml                         #
#------------------------------------------------------------------------------#

SRC_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# don't exit on error
set +e


function extract_var() {
    echo $1 | xpath -q -e '//element[@type='"'$2'"']/text()'
}


# Args: string
function homogenise() {
    echo -e $(to_lower $(despace "$1"))
}


# Args: section key file_path
read_conf_var() {
    echo $(sed -nr "/\[$1\]/,/\[/{/^(\W|)$2=/ { s/[^=]*=//; p }}" $3)
}


# Args: section key val file_path
write_conf_var() {
    sed -i -e "/^\[$1\]/,/^\[.*\]/ s|^\($2[ \t]*=[ \t]*\).*$|\1$4|" "$3"
}


# Args: state forecast_location day_index report_dict_ref
function fcast() {
    mapfile -t arr < "${TMUX_WEATHER_AU_DATA_DIR}/${1}.fcast_locations"
    array_has_value "$(homogenise "$2")" homogenise "${arr[@]}"
    if [ $? -eq 0 ]; then
        local DATA="$(echo $(<"${TMUX_WEATHER_AU_DATA_DIR}/${1}.fcast") | xpath -q -e '//area[@description='"'$2'"']/forecast-period[@index='"'$3'"']')"

        if [ $(($3)) -eq 0 ]; then
            local day="Today"
        elif [ $(($3)) -eq 1 ]; then
            local day="Tomorrow"
        else
            local datetime="$(echo $DATA | xpath -q -e 'string(//forecast-period[@index='"'$3'"']/@start-time-local)')"
            local day=$(date -d "${datetime:0:10}" +'%a')
        fi

        local forecast_location="$2"
        if [[ -v ALIAS["$2"] ]]; then
            local forecast_location="$(sed -e 's/^"//' -e 's/"$//' <<<${ALIAS["${2}"]})"
        fi

        dict_ref_append $4 "air_temperature_minimum" "$(echo $DATA | xpath -q -e '//element[@type='"'air_temperature_minimum'"']/text()')"
        dict_ref_append $4 "air_temperature_maximum" "$(echo $DATA | xpath -q -e '//element[@type='"'air_temperature_maximum'"']/text()')"
        dict_ref_append $4 "precipitation_range" "$(echo $DATA | xpath -q -e '//element[@type='"'precipitation_range'"']/text()')"
        dict_ref_append $4 "probability_of_precipitation" "$(echo $DATA | xpath -q -e '//text[@type='"'probability_of_precipitation'"']/text()')"
        dict_ref_append $4 "precis" "$(echo $DATA | xpath -q -e '//text[@type='"'precis'"']/text()')"     
        dict_ref_append $4 "day" "$day"
        dict_ref_append $4 "forecast_location" "$forecast_location"
    else
        dict_ref_append $4 "error" "Forecast location not found: $1:$2"
    fi
}


# Args: state station report_dict_ref
function obs() {
    mapfile -t arr < "${TMUX_WEATHER_AU_DATA_DIR}/${1}.obs_stations"
    array_has_value "$(homogenise "$2")" homogenise "${arr[@]}"
    if [ $? -eq 0 ]; then
        local DATA="$(echo $(<"${TMUX_WEATHER_AU_DATA_DIR}/${1}.obs") | xpath -q -e '//station[@description='"'$2'"']')"
        local utc="$(echo $DATA | xpath -q -e 'string(//period/@time-utc)')"
        local datetime="$(echo $DATA | xpath -q -e 'string(//period/@time-local)')"
        local hhmm="${datetime:11:5}"

        local station="$2"
        if [[ -v ALIAS[$2] ]]; then
            local station="$(sed -e 's/^"//' -e 's/"$//' <<<${ALIAS["${2}"]})"
        fi

        dict_ref_append $3 "apparent_temp" "$(extract_var "$DATA" apparent_temp)"
        dict_ref_append $3 "delta_t" "$(extract_var "$DATA" delta_t)"
        dict_ref_append $3 "gust_kmh" "$(extract_var "$DATA" gust_kmh)"
        dict_ref_append $3 "wind_gust_spd" "$(extract_var "$DATA" wind_gust_spd)"
        dict_ref_append $3 "air_temperature" "$(extract_var "$DATA" air_temperature)"
        dict_ref_append $3 "dew_point" "$(extract_var "$DATA" dew_point)"
        dict_ref_append $3 "pres" "$(extract_var "$DATA" pres)"
        dict_ref_append $3 "msl_pres" "$(extract_var "$DATA" msl_pres)"
        dict_ref_append $3 "qnh_pres" "$(extract_var "$DATA" qnh_pres)"
        dict_ref_append $3 "rain_hour" "$(extract_var "$DATA" rain_hour)"
        dict_ref_append $3 "rain_ten" "$(extract_var "$DATA" rain_ten)"
        dict_ref_append $3 "rel-humidity" "$(extract_var "$DATA" rel-humidity)"
        dict_ref_append $3 "wind_dir" "$(extract_var "$DATA" wind_dir)"
        dict_ref_append $3 "wind_dir_deg" "$(extract_var "$DATA" wind_dir_deg)"
        dict_ref_append $3 "wind_spd_kmh" "$(extract_var "$DATA" wind_spd_kmh)"
        dict_ref_append $3 "wind_spd" "$(extract_var "$DATA" wind_spd)"
        dict_ref_append $3 "utc" "${utc}"
        dict_ref_append $3 "datetime" "${datetime}"
        dict_ref_append $3 "time" "${hhmm}"
        dict_ref_append $3 "station" "$station"
    else
        dict_ref_append $3 "error" "Station not found: $1:$2"
    fi
}


# Args: report_rotation fcast_rotation path_to_src_dir path_to_conf_file
function main() {
    TMUX_WEATHER_AU_SRC_DIR=$3
    export TMUX_WEATHER_AU_SRC_DIR
    source "${SRC_DIR}"/bootstrap.sh

    TMUX_WEATHER_AU_CONF_FILE=$4
    source ${TMUX_WEATHER_AU_CONF_FILE}

    rm -f "${TMUX_WEATHER_AU_DATA_DIR}"/*.obs
    rm -f "${TMUX_WEATHER_AU_DATA_DIR}"/*.fcast

    local REPS=""
    local expiry=0
    local obs_endpoint
    local fcast_endpoint

    for d in "${REPORT[@]}"; do
        declare -A OREP
        declare -A FREP

        readarray -td '|' line <<<${d}
        for l in "${line[@]}"; do           
            readarray -td ';' dict <<<${l}

            # dynamically allocate report vars (from conf)
            for kv in "${dict[@]}"; do
                printf -v "$(dict_key "$kv")" "%s" "$(dict_val "$kv")"
            done
            
            if [ ! -z ${state+x} ]; then
                if [ ! -f "${TMUX_WEATHER_AU_DATA_DIR}/${state}.obs" ]; then  
                    # no data for this state, retrieve endpoint data, process, and write files...
                    echo "$(${TMUX_WEATHER_AU_SCRIPTS_DIR}/endpoint.sh stations ${state})" > "${TMUX_WEATHER_AU_DATA_DIR}/$state.obs_stations"
                    echo "$(${TMUX_WEATHER_AU_SCRIPTS_DIR}/endpoint.sh observations ${state})" > "${TMUX_WEATHER_AU_DATA_DIR}/$state.obs"
                    echo "$(${TMUX_WEATHER_AU_SCRIPTS_DIR}/endpoint.sh forecast_locations ${state})" > "${TMUX_WEATHER_AU_DATA_DIR}/$state.fcast_locations"
                    echo "$(${TMUX_WEATHER_AU_SCRIPTS_DIR}/endpoint.sh forecasts ${state})" > "${TMUX_WEATHER_AU_DATA_DIR}/$state.fcast"
                fi

                if [ ! -z ${station+x} ]; then
                    obs $state "$station" "OREP"
                    __es=$EPOCHSECONDS
                    __utc=$(date -d ${OREP["utc"]} +%s)
                    __next_rep=$(expr $__utc + 600)
                    if [ $__es -gt $expiry ]; then 
                        if [ $__next_rep -gt $__es ]; then
                            expiry=$__next_rep
                        fi
                    else
                        if [ $expiry -gt $__next_rep ]; then
                            if [ $__next_rep -gt $__es ]; then                           
                                expiry=$__next_rep
                            fi
                        fi
                    fi
                fi
                
                if [ ! -z ${forecast_location+x} ]; then
                    if [ -z ${days+x} ]; then
                        days="[1]" # tomorrows forecast
                    fi
                    readarray -td ' ' a_days <<<$(sed 's/[][]//g' <<<$days)
                    dict_ref_append "OREP" "n_fcast" "${#a_days[@]}"
                    REPS="${REPS}$(save_dict OREP)"$'\n'
                    for i in "${a_days[@]}"; do
                        fcast $state "$forecast_location" $i "FREP"
                        REPS="${REPS}$(save_dict FREP)"$'\n'
                    done
                fi
            fi

            unset forecast_location
            unset station
            unset state
            unset days
        done

        unset OREP
        unset FREP
    done

    # Clear reports file
    >"${OUTFILE}"
    
    # Headers
    # line 1: expiry: ten minutes after this observation (as per BOM updates)
    # line 2: total number of lines in file
    #         - includes the 4 header lines and all report lines, minus 
    #           the trailing newline at the end of the file.
    # line 3: obs rotation
    # line 4: fcast rotation

    printf "%s\n" $expiry >>"${OUTFILE}"
    printf "%s\n" $(expr $(sed -n '$=' <<<$REPS) + 3) >>"${OUTFILE}"
    printf "%s\n" $1 >>"${OUTFILE}"
    printf "%s\n" $2 >>"${OUTFILE}"
    printf "%s" "$REPS" >>"${OUTFILE}"

    exit 0
}


#------------------------------------------------------------------------------#
#                                   main                                       #
#------------------------------------------------------------------------------#
main $1 $2 $3 $4
