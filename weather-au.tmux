#!/bin/bash

set -o errexit
set -o pipefail

#TMUX_WEATHER_AU_SRC_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TMUX_WEATHER_AU_SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_WEATHER_AU_SRC_DIR

source "${TMUX_WEATHER_AU_SRC_DIR}"/scripts/bootstrap.sh
source "${TMUX_WEATHER_AU_SCRIPTS_DIR}"/weather-au

main() {
    TMUX_WEATHER_AU_CONF_FILE=$1
    source ${TMUX_WEATHER_AU_CONF_FILE}
    source ${TMUX_WEATHER_AU_THEMES_DIR}/$THEME

    declare -A out=()
    parse_report out

    fcast="$FCAST_LABEL__ ${out["fcast_label"]}$__FCAST_LABEL $FCAST_DATA__${out["fcast_data"]} $__FCAST_DATA"
    obs="$OBS_LABEL__ ${out["obs_label"]}$__OBS_LABEL $OBS_DATA__${out["obs_data"]} $__OBS_DATA"
    tmux set-option -g status-format[1] "$fcast$obs"
   
    exit 0
}

#------------------------------------------------------------------------------#
#                              main entry point                                #
#------------------------------------------------------------------------------#

if [ $# -eq 0 ]; then
    echo $TMUX_WEATHER_AU_SRC_DIR
    main "${TMUX_WEATHER_AU_SRC_DIR}"/conf.sh
else
    for arg in "$@"
    do
        k=$(echo $arg | cut -f1 -d=)
        v=$(echo $arg | cut -f2 -d=)
        case "$k" in
            --conf) main "$v";;
            *)
        esac
    done   
fi
