## Weather forcasts and observations from BOM data in your tmux status bar
WIP. No docs yet. 

The following snippet example goes somewhere in your .tmux.conf

```
WEATHER_AU="#(~/.tmux/plugins/tmux_weather_au/weather_au.tmux)"
set -g status-format[1] "$WEATHER_AU"
```