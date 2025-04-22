# Default weather-au theme

POSITION="#[align=right]"
ORIENTATION="right"

STATUS_BAR_BG='colour235' # faded green
STATUS_BAR_FG='colour108' # dark grey
STATUS_BAR_STYLE="#[default,bg=$STATUS_BAR_BG,fg=$STATUS_BAR_FG]"

LABEL_BG='colour114' # green
LABEL_FG='colour000' # black
LABEL_STYLE="#[default,bg=$LABEL_BG,fg=$LABEL_FG]"

DATA_BG='colour238' # grey
DATA_FG='colour114' # green
DATA_STYLE="#[default,bg=$DATA_BG,fg=$DATA_FG]"

RARROW="#[default,bg=$LABEL_BG,fg=$STATUS_BAR_BG]"
RARROW_BOLD="#[default,bg=$DATA_BG,fg=$LABEL_BG,bold]"
RBITE_BOLD="#[default,bg=$LABEL_BG,fg=$STATUS_BAR_BG,bold]"


RDATA_ARROW_BOLD="#[default,bg=$STATUS_BAR_BG,fg=$DATA_BG,bold]"


FCAST_LABEL__="$POSITION$RBITE_BOLD$LABEL_STYLE"
__FCAST_LABEL=$RARROW_BOLD

FCAST_DATA__="$DATA_STYLE"
__FCAST_DATA="$RDATA_ARROW_BOLD"

OBS_LABEL__="$RBITE_BOLD$LABEL_STYLE"
__OBS_LABEL=$RARROW_BOLD

OBS_DATA__="$DATA_STYLE"
__OBS_DATA="$RDATA_ARROW_BOLD"

# 
# 
# 
# 
