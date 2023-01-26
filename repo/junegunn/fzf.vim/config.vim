" for advanced rg integration, please see:
" https://github.com/junegunn/fzf.vim#example-advanced-ripgrep-integration
command! -bang -nargs=* LinFzfUnrestrictedRg
            \ call fzf#vim#grep(
            \ "rg --column --no-heading --color=always -S -uu --glob=!.git/ ".shellescape(<q-args>), 1,
            \ fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=0 LinFzfRgCWord
            \ call fzf#vim#grep(
            \ "rg --column --no-heading --color=always -S ".shellescape(expand('<cword>')), 1,
            \ fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=0 LinFzfUnrestrictedRgCWord
            \ call fzf#vim#grep(
            \ "rg --column --no-heading --color=always -S -uu --glob=!.git/ ".shellescape(expand('<cword>')), 1,
            \ fzf#vim#with_preview(), <bang>0)

if executable('fd')
    command! -bang -nargs=? -complete=dir LinFzfUnrestrictedFiles
        \ call fzf#run(
        \   fzf#vim#with_preview(
        \     fzf#wrap({ 'source': 'fd -tf -tl -i -u --exclude ".git" '.shellescape(<q-args>) }, <bang>0)
        \   )
        \ )
elseif executable('fdfind')
    command! -bang -nargs=? -complete=dir LinFzfUnrestrictedFiles
        \ call fzf#run(
        \   fzf#vim#with_preview(
        \     fzf#wrap({ 'source': 'fdfind -tf -tl -i -u --exclude ".git" '.shellescape(<q-args>) }, <bang>0)
        \   )
        \ )
endif


""" Text
" live grep
nnoremap <silent> <space>r      :FzfRg<CR>
nnoremap <silent> <space>ur     :LinFzfUnrestrictedRg<CR>
" cursor word/string
nnoremap <silent> <space>w      :LinFzfRgCWord<CR>
nnoremap <silent> <space>uw     :LinFzfUnrestrictedRgCWord<CR>
" lines in opened buffers
nnoremap <silent> <space>ln     :FzfLines<CR>
" tags
nnoremap <silent> <space>tg     :FzfTags<CR>

""" Files
" files
nnoremap <silent> <space>f      :FzfFiles<CR>
nnoremap <silent> <C-p>         :FzfFiles<CR>
nnoremap <silent> <space>uf     :LinFzfUnrestrictedFiles<CR>
" opened buffers
nnoremap <silent> <space>b      :FzfBuffers<CR>
" history files/oldfiles
nnoremap <silent> <space>hf     :FzfHistory<CR>

""" History
" search history
nnoremap <silent> <space>hs     :FzfHistory/<CR>
" vim command history
nnoremap <silent> <space>hc     :FzfHistory:<CR>

""" Lsp
" diagnostics in current buffer
nnoremap <silent> <space>db     :LspDiagnostics 0<CR>
" all diagnostics
nnoremap <silent> <space>da     :LspDiagnosticsAll<CR>

""" Git
" git commits
nnoremap <silent> <space>gc     :FzfCommits<CR>
" git files
nnoremap <silent> <space>gf     :FzfGFiles<CR>
" git status files
nnoremap <silent> <space>gs     :FzfGFiles?<CR>

""" Vim
" vim marks
nnoremap <silent> <space>mk     :FzfMarks<CR>
" vim key mappings
nnoremap <silent> <space>mp     :FzfMaps<CR>
" vim commands
nnoremap <silent> <space>cm     :FzfCommands<CR>
" vim help tags
nnoremap <silent> <space>ht     :FzfHelptags<CR>
" vim colorschemes
nnoremap <silent> <space>cs     :FzfColors<CR>
" vim filetypes
nnoremap <silent> <space>tp     :FzfFiletypes<CR>