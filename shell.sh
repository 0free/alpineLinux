#!/bin/ash

#format
export textReset='\[\e[0m\]'
export textBold='\[\e[1m\]'
export textDim='\[\e[2m\]'
export textBlink='\[\e[5m\]'
export textHidden='\[\e[8m\]'
export textInvert='\[\e[7m\]'
export textDefault='\[\e[21m\]'

#foreground
export color30='\[\e[30m\]'
export color31='\[\e[31m\]'
export color32='\[\e[32m\]'
export color33='\[\e[33m\]'
export color34='\[\e[34m\]'
export color35='\[\e[35m\]'
export color36='\[\e[36m\]'
export color37='\[\e[37m\]'
export color38='\[\e[38m\]'
export color39='\[\e[39m\]'

export color90='\[\e[90m\]'
export color91='\[\e[91m\]'
export color92='\[\e[92m\]'
export color93='\[\e[93m\]'
export color94='\[\e[94m\]'
export color95='\[\e[95m\]'
export color96='\[\e[96m\]'
export color97='\[\e[97m\]'
export color98='\[\e[98m\]'
export color99='\[\e[99m\]'

#background
export color40='\[\e[40m\]'
export color41='\[\e[41m\]'
export color42='\[\e[42m\]'
export color43='\[\e[43m\]'
export color44='\[\e[44m\]'
export color45='\[\e[45m\]'
export color46='\[\e[46m\]'
export color47='\[\e[47m\]'
export color48='\[\e[48m\]'
export color49='\[\e[49m\]'

export color100='\[\e[100m\]'
export color101='\[\e[101m\]'
export color102='\[\e[102m\]'
export color103='\[\e[103m\]'
export color104='\[\e[104m\]'
export color105='\[\e[105m\]'
export color106='\[\e[106m\]'
export color107='\[\e[107m\]'
export color108='\[\e[108m\]'
export color109='\[\e[109m\]'

#terminal
export PS1="\n$color102 \h $color104 \u $color105 $SHELL $color106 \w $textReset\n\n$color101$color92 ❯ $textReset "

#bash-completion
if [ -f /etc/bash/bash_completion.sh ]; then
    . /etc/bash/bash_completion.sh
fi
