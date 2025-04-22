#!/bin/bash

#------------------------------------------------------------------------------#
# Bootstraps global constants and sources utility functions                    #
#------------------------------------------------------------------------------#

TMUX_WEATHER_AU_SCRIPTS_DIR=${TMUX_WEATHER_AU_SRC_DIR}/scripts
TMUX_WEATHER_AU_THEMES_DIR=${TMUX_WEATHER_AU_SRC_DIR}/themes
TMUX_WEATHER_AU_DATA_DIR=${TMUX_WEATHER_AU_SRC_DIR}/data

OUTFILE="$TMUX_WEATHER_AU_DATA_DIR"/fcast_obs

source "$TMUX_WEATHER_AU_SCRIPTS_DIR"/util.sh
