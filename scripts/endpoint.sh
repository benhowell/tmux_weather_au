#!/bin/bash

# don't exit on error
set +e

# end-points
NSW_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDN60920.xml
NSW_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11020.xml
# ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml

TAS_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDT60920.xml
TAS_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDT16710.xml #long form

NT_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDD60920.xml
NT_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDD10207.xml
# ftp://ftp.bom.gov.au/anon/gen/fwo/IDD10207.xml

QLD_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ60920.xml
QLD_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ10606.xml
# ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml

SA_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDS60920.xml
SA_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDS11055.xml
# ftp://ftp.bom.gov.au/anon/gen/fwo/IDS10044.xml

VIC_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDV60920.xml
VIC_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDV10750.xml
# ftp://ftp.bom.gov.au/anon/gen/fwo/IDV10753.xml

WA_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDW60920.xml
WA_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDW13010.xml
# ftp://ftp.bom.gov.au/anon/gen/fwo/IDW14199.xml


function write_data() {
    data="$(curl -s ${!1})"
    if [ $# -eq 1 ]; then
        echo $data
    else
        extract="$(echo $data | xpath -q -e "$2")"
        #strip leading text and double quotes, convert to lowercase
        for i in "$extract"; do
            echo "$i" | sed -e 's/\sdescription=//g' -e 's/\"//g'; 
        done
    fi
}


#------------------------------------------------------------------------------#
#                                   main                                       #
#------------------------------------------------------------------------------#
if [ $# -ne 2 ]; then
    echo "USAGE: $0 operation state"
    echo "operation:"
    echo "  stations"
    echo "  forecast_locations"
    echo "  observations"
    echo "  forecasts"
    echo "state:"
    echo "  NSW"
    echo "  TAS"
    echo "  NT"
    echo "  QLD"
    echo "  SA"
    echo "  VIC"
    echo "  WA"
    echo "examples:"
    echo "  endpoint.sh stations TAS"
    echo "  endpoint.sh forecast_locations TAS"
    echo "  endpoint.sh observations TAS"
    echo "  endpoint.sh forecasts TAS"
else
    case "$1" in
        "stations") write_data "$2_OBS" '//station/@description';;
        "forecast_locations") write_data "$2_FCAST" '//area[@type='"'location'"']/@description';;
        "observations") write_data "$2_OBS";;
        "forecasts") write_data "$2_FCAST";;
        *)
    esac
fi
