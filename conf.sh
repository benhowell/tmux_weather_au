

# Report
# ------ 
#   A list of all reports to deliver. Each report consists of the current
#   phenomena observation, and forecast(s) for the days listed (0 = today,
#   1 = tomorrow, ...). If 'days' parameter omitted, tomorrows forecast is
#   assumed (i.e. days=[1]).
#
#   Format: OBS|FCAST
declare -a REPORT=(
    "state=TAS;station=Hobart|state=TAS;forecast_location=Hobart;days=[0 1 2]"
    "state=TAS;station=Hobart|state=TAS;forecast_location=Bellerive;days=[1 2]"
    "state=TAS;station=Hobart Bushland Operations Depot (HCC)|state=TAS;forecast_location=Hobart;days=[1]")


# Alias
# ----- 
#  Aliases to substitute for station and forecast_locations names. Aliases are
#  only applied to the final data and formatted report output. Used to apply
#  readable names in formatted report snippets.
declare -A ALIAS=(
    ["Hobart Bushland Operations Depot (HCC)"]="Huon Rd"
    ["Hobart Airport"]="Airport"
    ["Kunanyi/Mount Wellington"]="Mountain"
    ["kunanyi /Mount Wellington"]="Mountain"
    ["Hartz Mountains"]="Hartz Mt"
    ["Dennes Point"]="Dennes Pt"
    ["Bushy Park"]="Bushy Pk"
    ["Adventure Bay"]="Adv Bay")


THEME="default.sh"

OBS_VARS_FMT=""
declare -a OBS_LABEL=("%s %s ;station,time")
declare -a OBS_VARS=(
    "%'.0f/%'.0f%s ;apparent_temp,air_temperature,units_air_temperature" 
    "┃ %s/%s %s %s ;wind_spd_kmh,gust_kmh,units_wind_spd_kmh,wind_dir" 
    "┃ %s%s ;rel-humidity,units_rel-humidity"
    "┃ %s %s;pres,units_pres")

declare -a FCAST_LABEL=("%s %s ;forecast_location,day")
declare -a FCAST_VARS=(
    "%s ;precis"
    "[%s %s] ;probability_of_precipitation,precipitation_range|[%s] ;probability_of_precipitation"
    "%s/%s%s;air_temperature_minimum,air_temperature_maximum,units_air_temperature_maximum|%s%s;air_temperature_maximum,units_air_temperature_maximum"
    )
