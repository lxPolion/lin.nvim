""" Use fd for fzf file finding, instead of default find
if executable('fd')
    let $FZF_DEFAULT_COMMAND = 'fd -tf -tl -i'
elseif executable('fdfind')
    let $FZF_DEFAULT_COMMAND = 'fdfind -tf -tl -i'
endif
let $BAT_THEME = 'base16'

""" Fzf command prefix
let g:fzf_command_prefix = 'Fzf'
