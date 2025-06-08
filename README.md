# tmux_weather_au
Live weather forecasts and observations from the Australian Bureau of 
Meteorology (BOM) in your tmux status bar.

`tmux_weather_au` is written in `bash` and utilises anonymous FTP access to BOM 
forecast and observation data.

![Screenshot](/doc/example3.png)

## Requirements
- `tmux`
- `bash --version` >= 3.2
- Nerd font. Installation instructions here: [font installation](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-installation]).


## Installation
`tmux_weather_au` can be installed in a couple of ways:
1. Via [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm/)
```
set -g @plugin 'benhowell/tmux_weather_au'
```
Add the following snippet somewhere in your `.tmux.conf`

```
WEATHER_AU="#(~/.tmux/plugins/tmux_weather_au/weather_au.tmux)"
set -g status-format[1] "$WEATHER_AU"
```

**or**

2. Download the [source](https://github.com/benhowell/tmux_weather_au/archive/refs/heads/main.zip) 
and extract it to `<path of your choice>`.

Add the following snippet somewhere in your `.tmux.conf`

```
WEATHER_AU="#(<path of your choice>)"
set -g status-format[1] "$WEATHER_AU"
```


## Configuration
`conf.sh` is where configuration data lives. The source code for 
`tmux_weather_au` contains a pre-filled and commented `conf.sh` file for 
reference.

### Options

* Theme

  ```
  THEME="default.sh"
  ```

  Defines label, segment, and arrow colours, as well as arrow design. The 
  default theme is inspired by `tmux-powerline`.

  To apply a different theme, place the theme file in the `theme` folder and 
  change the `THEME` option to the name of that file.

---

* Align

  ```
  ALIGN="right"
  #ALIGN="left"
  #ALIGN="centre"
  ```

  Determines the alignment of the widget, e.g. `ALIGN="right"` will align the 
  widget to the right end of the status bar, conversely, `ALIGN="left"` will 
  align the widget to the left end of the status bar.

---

* Leftmost

  ```
  LEFTMOST="fcast"
  #LEFTMOST="obs"
  ```
 
  Determines the order of forecast(s) and observation, e.g. `LEFTMOST="obs"` 
  will place the observation leftmost, conversely, `LEFTMOST="fcast"` will place
  the forecast(s) leftmost.

---

* Orientation

  ```
  ORIENTATION="right"
  #ORIENTATION="left"
  ```

  Determines the label/segment and arrow orientation: 
  - `ORIENTATION="right"` will produce: 
    
    label > segment > .. > label > segment > ..

  - `ORIENTATION="left"` will produce:

    .. < segment < label < .. < segment < label 

---

* Report

  Format: OBS|FCAST
  ```
  declare -a REPORT=(
    "state=TAS;station=Hobart|state=TAS;forecast_location=Hobart;days=[0 1 2 3 4]"
    "state=TAS;station=Hobart|state=TAS;forecast_location=Bellerive;days=[1 2]"
    "state=TAS;station=Hobart Bushland Operations Depot (HCC)|state=TAS;forecast_location=Hobart;days=[1]")
  ```

  A list of all reports to deliver. Each report consists of the current
  phenomena observations, and forecast(s) for the days listed (0 = today,
  1 = tomorrow, ...). If `days` parameter omitted, tomorrows forecast is
  assumed (i.e. `days=[1]`).

  Each OBS|FCAST line in `REPORT` is rendered in the status bar on a rotation.
  Each FCAST day is rendered on a rotation. In the example above, 
  the first line means the current observations for `station=Hobart` are 
  rendered and for each day in `days` the forecast for `forecast_location=Hobart`
  are rendered in rotation from 0 (today) to 4. Once complete, the second line 
  in `REPORT` is executed, etc.

  Required parameters

  OBS
  - state: The state for observations (NSW, TAS, NT, QLD, SA, VIC, WA)
  - station: The station name to source observation data from

  FCAST
  - state: The state for forecast(s) (NSW, TAS, NT, QLD, SA, VIC, WA)
  - forecast_location: The location name to source forecast(s) data from

  Optional parameters

  FCAST
  - days: List of days to fetch forecasts for (0 = today, 1 = tomorrow, etc)

---

* Alias

  ```
  declare -A ALIAS=(
    ["Hobart Bushland Operations Depot (HCC)"]="Huon Rd"
    ["Hobart Airport"]="Airport"
    ["Kunanyi/Mount Wellington"]="Mountain"
    ["kunanyi /Mount Wellington"]="Mountain"
    ["Hartz Mountains"]="Hartz Mt"
    ["Dennes Point"]="Dennes Pt"
    ["Bushy Park"]="Bushy Pk"
    ["Adventure Bay"]="Adv Bay")
  ```
  
  Provides a mechanism to substitute aliases for station and forecast_locations 
  names. Aliases are only applied to the final data and widget render. Use to 
  apply readable names in reports.

---

* Observation label

  ```
  declare -a OBS_LABEL=("%s %s;station,time")
  ```
  
  `printf` formatted label for observations. The label can contain any 
  combination of any observation variable formatted to your choosing. 

  See (Output variables)[https://github.com/benhowell/tmux_weather_au?tab=readme-ov-file#output-variables] for available variables.

---

* Observation variables

  ```
  declare -a OBS_VARS=(
      "%.0f/%.0f%s;apparent_temp,air_temperature,units_air_temperature" 
      "%s/%s %s %s;wind_spd_kmh,gust_kmh,units_wind_spd_kmh,wind_dir" 
      "%s%s;rel-humidity,units_rel-humidity"
      "%.0f %s;pres,units_pres"
      )
  ```

  `printf` formatted observation data. Each line represents one section in the 
  `tmux_weather_au` status bar widget. Data can contain any 
  combination of any observation variable formatted to your choosing. 

  See (Output variables)[https://github.com/benhowell/tmux_weather_au?tab=readme-ov-file#output-variables] for available variables.

  See (Unit measurement constants)[https://github.com/benhowell/tmux_weather_au?tab=readme-ov-file#unit-measurement-constants] for available measurement units.

---

* Forecast label

  ```
  declare -a FCAST_LABEL=("%s %s;forecast_location,day")
  ```

  `printf` formatted label for forecasts. The label can contain any 
  combination of any forecast variable formatted to your choosing. 

  See (Output variables)[https://github.com/benhowell/tmux_weather_au?tab=readme-ov-file#output-variables] for available variables.

---

* Forecast variables

  Format: preferred_output_1|preferred_output_2|...

  ```
  declare -a FCAST_VARS=(
      "%s;precis"
      "%s %s;probability_of_precipitation,precipitation_range|%s;probability_of_precipitation"
      "%s/%s%s;air_temperature_minimum,air_temperature_maximum,units_air_temperature_maximum|%s%s;air_temperature_maximum,units_air_temperature_maximum"
      )
  ```

  `printf` formatted forecast data. Each line represents one section in the 
  `tmux_weather_au` status bar widget. Data can contain any combination of any 
  forecast variable formatted to your choosing.

  As some data may not be available at all times, a list of preferred output
  may be specified with pipe delimiters. 

  In the example above, the second line will render the result of 
  `%s %s;probability_of_precipitation,precipitation_range` if 
  `probability_of_precipitation` and `precipitation_range` data are both 
  available. If one or more variables have no data available, the next option
  will be tried, i.e. `%s;probability_of_precipitation`. This process continues 
  left to right along the line until either an option is able to be fulfilled, 
  or all options are exhausted, in which case, nothing is rendered.

  See (Output variables)[https://github.com/benhowell/tmux_weather_au?tab=readme-ov-file#output-variables] for available variables.

  See (Unit measurement constants)[https://github.com/benhowell/tmux_weather_au?tab=readme-ov-file#unit-measurement-constants] for available measurement units.


### Output variables

Output variables provide forecast and observation phenomenon data. All variables are optional.

| Variable                     | Type        |
|:-----------------------------|:------------|
| forecast_location            | forecast    |
| day                          | forecast    |
| air_temperature_minimum      | forecast    |
| air_temperature_maximum      | forecast    |
| precipitation_range          | forecast    |
| probability_of_precipitation | forecast    |
| precis                       | forecast    |
| station                      | observation |
| time                         | observation |
| datetime                     | observation |
| utc                          | observation |
| apparent_temp                | observation |
| delta_t                      | observation |
| gust_kmh                     | observation |
| wind_gust_spd                | observation |
| air_temperature              | observation |
| dew_point                    | observation |
| pres                         | observation |
| msl_pres                     | observation |
| qnh_pres                     | observation |
| rain_hour                    | observation |
| rain_ten                     | observation |
| rel-humidity                 | observation |
| wind_dir                     | observation |
| wind_dir_deg                 | observation |
| wind_spd_kmh                 | observation |
| wind_spd                     | observation |


### Unit measurement constants

Unit constants are predictably named with a `units_` prefix to the variable for 
which the unit applies. For example the unit for `wind_spd` is `units_wind_spd`.
All constants are optional.

| Name                          | Measurement unit | 
|:------------------------------|:-----------------|
| units_wind_spd_kmh            | km/h             |
| units_wind_spd                | kn               |
| units_gust_kmh                | km/h             |
| units_wind_gust_spd           | kn               |
| units_wind_dir_deg            | &deg;            |
| units_apparent_temp           | &deg;C           |
| units_air_temperature         | &deg;C           |
| units_delta_t                 | &deg;C           |
| units_dew_point               | &deg;C           |
| units_pres                    | hPa              |
| units_msl_pres                | hPa              |
| units_qnh_pres                | hPa              |
| units_rain_hour               | mm               |
| units_rain_ten                | mm               |
| units_rel-humidity            | % RH             |
| units_air_temperature_minimum | &deg;C           |
| units_air_temperature_maximum | &deg;C           |


### Screenshots

![Screenshot](/doc/example1.png)

![Screenshot](/doc/example2.png)

![Screenshot](/doc/example3.png)

![Screenshot](/doc/example4.png)

![Screenshot](/doc/example5.png)

