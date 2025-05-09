# Default weather-au theme

STATUS_BAR_BG='colour235' # dark grey
STATUS_BAR_FG='colour108' # faded green
STATUS_BAR_TEXT=$STATUS_BAR_FG # faded green

LABEL_BG='colour114' # green
LABEL_FG='colour000' # black
LABEL_TEXT=$LABEL_FG # black

SEG_BG0='colour239' # grey
SEG_BG1='colour237' # grey
SEG_TEXT=$LABEL_BG

STATUS_BAR_STYLE="#[default,bg=$STATUS_BAR_BG,fg=$STATUS_BAR_TEXT]"
LABEL_STYLE="#[default,bg=$LABEL_BG,fg=$LABEL_TEXT]"
SEG_STYLE0="#[default,bg=$SEG_BG0,fg=$SEG_TEXT]"
SEG_STYLE1="#[default,bg=$SEG_BG1,fg=$SEG_TEXT]"

LEFT_BOLD=""
LEFT_THIN=""
RIGHT_BOLD=""
RIGHT_THIN=""

LABEL_ARROW_BOLD="#[default,bg=$SEG_BG0,fg=$LABEL_BG,bold]"
SEG_ARROW_BOLD0="#[default,bg=$SEG_BG1,fg=$SEG_BG0,bold]"
SEG_ARROW_BOLD1="#[default,bg=$LABEL_BG,fg=$SEG_BG1,bold]"
SEG_ARROW_BOLD2="#[default,bg=$STATUS_BAR_BG,fg=$SEG_BG1,bold]"
SEG_ARROW_THIN0="#[default,bg=$SEG_BG1,fg=$LABEL_BG]"
