""" Use fd for fzf file finding, instead of default find
if executable('fd')
    let $FZF_DEFAULT_COMMAND = 'fd -tf -tl -i -u --exclude ".git"'
elseif executable('fdfind')
    let $FZF_DEFAULT_COMMAND = 'fdfind -tf -tl -i -u --exclude ".git"'
endif
let $BAT_THEME = 'base16'

""" Fzf command prefix
let g:fzf_command_prefix = 'Fzf'

" for advanced rg integration, please see:
" https://github.com/junegunn/fzf.vim#example-advanced-ripgrep-integration
command! -bang -nargs=* LinFzfRg
            \ call fzf#vim#grep(
            \ "rg --column --no-heading --color=always -S -u -u --glob=!.git/ -- ".shellescape(<q-args>), 1,
            \ fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=0 LinFzfRgCWord
            \ call fzf#vim#grep(
            \ "rg --column --no-heading --color=always -S -u -u --glob=!.git/ ".shellescape(expand('<cword>')), 1,
            \ fzf#vim#with_preview(), <bang>0)

function! s:LinDefineFzfKeys(k, v) abort
    execute printf('nnoremap <silent> <expr> %s (&filetype ==# "NvimTree" ? "\<C-w>\<C-w>" : "").":%s\<CR>"', a:k, a:v)
endfunction

""" Text
" live grep
call s:LinDefineFzfKeys('<space>r', 'LinFzfRg')
" cursor word/string
call s:LinDefineFzfKeys('<space>w', 'LinFzfRgCWord')
" lines in opened buffers
call s:LinDefineFzfKeys('<space>ln', 'FzfLines')
" tags
call s:LinDefineFzfKeys('<space>tg', 'FzfTags')

""" History
" search history
call s:LinDefineFzfKeys('<space>sh', 'FzfHistory/')
" vim command history
call s:LinDefineFzfKeys('<space>ch', 'FzfHistory:')

""" Files
" files
call s:LinDefineFzfKeys('<space>f', 'FzfFiles')
call s:LinDefineFzfKeys('<C-p>', 'FzfFiles')
" opened buffers
call s:LinDefineFzfKeys('<space>b', 'FzfBuffers')
" history files/oldfiles
call s:LinDefineFzfKeys('<space>hf', 'FzfHistory')

""" Lsp
" all diagnostics
call s:LinDefineFzfKeys('<space>dg', 'LspDiagnosticsAll')

""" Git
" git commits
call s:LinDefineFzfKeys('<space>gc', 'FzfCommits')
" git files
call s:LinDefineFzfKeys('<space>gf', 'FzfGFile')
" git status files
call s:LinDefineFzfKeys('<space>gs', 'FzfGFiles?')

""" Vim
" vim marks
call s:LinDefineFzfKeys('<space>mk', 'FzfMarks')
" vim key mappings
call s:LinDefineFzfKeys('<space>mp', 'FzfMaps')
" vim commands
call s:LinDefineFzfKeys('<space>cm', 'FzfCommands')
" vim help tags
call s:LinDefineFzfKeys('<space>ht', 'FzfHelptags')
" vim colorschemes
call s:LinDefineFzfKeys('<space>cs', 'FzfColors')
" vim filetypes
call s:LinDefineFzfKeys('<space>ft', 'FzfFiletypes')
