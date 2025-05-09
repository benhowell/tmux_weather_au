#!/bin/bash

TMUX_WEATHER_AU_SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_WEATHER_AU_SRC_DIR
source "${TMUX_WEATHER_AU_SRC_DIR}"/scripts/bootstrap.sh

main() {
    TMUX_WEATHER_AU_CONF_FILE=$1
    source ${TMUX_WEATHER_AU_CONF_FILE}
    source ${TMUX_WEATHER_AU_THEMES_DIR}/$THEME
    source "${TMUX_WEATHER_AU_SCRIPTS_DIR}"/weather-au

    parse_report
}

#------------------------------------------------------------------------------#
#                              main entry point                                #
#------------------------------------------------------------------------------#

if [ $# -eq 0 ]; then
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
