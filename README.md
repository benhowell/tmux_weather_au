WIP. No docs yet. The following snippet example goes somewhere in your .tmux.conf

### Weather forcasts and observations
WEATHER_AU="#(~/.tmux/plugins/tmux_weather_au/weather_au.tmux)"
set -g status-format[1] "$WEATHER_AU"