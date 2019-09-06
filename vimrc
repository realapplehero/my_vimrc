" ======== Hot Keys ========

nnoremap ee :tabnew ~/.vimrc<CR>
nnoremap ss :source ~/.vimrc<CR>
nnoremap ww :w<CR>
nnoremap qq :q!<CR>
nnoremap <Space> za
nnoremap <Tab> gt
nnoremap <S-Tab> gT

" <F1> reserved for help document of vim
map <F2> <ESC>:TagbarToggle<CR>
map <F3> <ESC>:CtrlP<CR>
map <F4> <ESC>:CtrlSF

map <F5> <ESC>:Gitv<CR>
map <F6> <ESC>:Gblame<CR>
map <F7> <ESC>:Gvdiff<CR>
map <F8> <ESC>:UndotreeToggle<CR>

map <F9> <ESC>:SyntasticToggleMode<CR>
map <F10> <ESC>:IndentLinesToggle<CR>
" <F11> reserved for help document of terminator
map <F12> <ESC>:NERDTreeToggle<CR>

let mapleader = ';'

" ======== Function ========

" For C/ShellScript/Java/JavaScript
" To fold the first two level code sections if match below indent format:
" class foo
" {
"     function xxx()
"     {
"         ...
"     }
" }
function! FoldFunction()
    let line = getline(v:lnum)
    if match(line, '^{$') > -1
        return '>1'
    elseif match(line, '^}$') > -1
        return '<1'
    elseif match(line, '^[ ]\{4\}{$') > -1
        return '>2'
    elseif match(line, '^[ ]\{4\}}$') > -1
        return '<2'
    else
        return '='
endfunction

" To show the trailing space
function! ShowTrailingSpace()
    highlight ExtraWhitespace ctermbg=red guibg=red
    match ExtraWhitespace /\s\+$/
endfunction

" To remove the trailing space
function! RemoveTrailingSpace()
    exe 'normal mz'
    %s/\s\+$//ge
    exe 'normal `z'
endfunction

" :tj <wordOnCursor>
function! MyTargbarShowTag()
    let l:wordOnCursor = expand('<cword>')
    exec ':tj ' . wordOnCursor
endfunction

function! AddFunctionDoc()
    " Check the cursor is in the line of function
    let l:cursorLine = getline('.')
    " TODO: the signature of function may have multiple lines
    let l:paramString = matchstr(l:cursorLine, '(.*)')
    if l:paramString == ''
        echoerr '[Error]: The cursor is NOT in the line of function declaration.'
        return ''
    else
        let l:funcString = matchstr(l:cursorLine, '[_[:alpha:]]*[[:blank:]]*(')
        let l:funcName = substitute(l:funcString, '[ (]', '', 'g')
        if l:funcName == '' || l:funcName == 'for' || l:funcName == 'while' || l:funcName == 'if' || l:funcName == 'switch' || l:funcName == 'catch'
            echoerr '[Error]: The cursor is NOT in the line of function declaration.'
            return ''
        endif
    endif

    " Transfer function parameter string to list
    let l:paramList = split(substitute(l:paramString, '[()]', '', 'g'), '[[:blank:]]*,[[:blank:]]*')

    " Create the document string
    let l:ft = &filetype
    if l:ft == 'javascript' || l:ft == 'java' || l:ft =='c' || l:ft == 'html'
        " Javadoc style
        " FIXME: the star char will cause some wrong indent in command
        "        exec 'normal O' . line
        let l:startDocBlock = '/**'
        let l:innerDocBlock = '\* '
        let l:endDocBlock = '\*/'
        let l:tagList = ['@brief', '']
        for param in l:paramList
            let l:tagList += ['@param ' . param]
        endfor
        let l:tagList += ['', '@return']
    elseif l:ft == 'sh'
        let l:startDocBlock = '##'
        let l:innerDocBlock = '#'
        let l:endDocBlock = '# '
        let l:tagList = ['  input: ', '', ' output: ']
    elseif l:ft == 'python'
        " FIXME: the space char will cause some wrong indent in command
        "        exec 'normal o' . line
        let l:startDocBlock = '"""' . l:funcName
        let l:innerDocBlock = ''
        let l:endDocBlock = '"""'
        let l:tagList = ['\n', 'Parameters']
        for param in l:paramList
            let l:tagList += ['==> ' . param]
        endfor
        let l:tagList += ['\n', 'Returns', '==> <retval>']
    else
        echoerr '[Error]: Only support filetype in [c, java, javascript, sh, python]'
        return ''
    endif

    " Combine the final content of comments
    let l:docContent = [l:startDocBlock]
    for line in l:tagList
        let l:docContent += [ l:innerDocBlock . line]
    endfor
    let l:docContent += [l:endDocBlock]

    " Write the content of comments above/below function declaration line
    if l:ft == 'python'
        for line in l:docContent
            exec 'normal! o' . line
        endfor
        startinsert!
    else
        for line in reverse(l:docContent)
            exec 'normal! O' . line
        endfor
        " startinsert!
    endif

endfunction

" ======== Option ========

set autoindent
set number
set cursorline
set tabstop=40
set softtabstop=4
set shiftwidth=4
set hlsearch
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
colorscheme koehler

hi Nontext ctermfg=grey guifg=grey
hi SpecialKey ctermfg=grey guifg=grey

" Exclude some files
let g:ExcludedFileExtension = '\v\.(exe|so|dll|pyc|zip|tar|tar.gz|tar.xz|tar.bz2|class|doc|png|jpg|jpeg)$'

" GUI Settings (gvim)
set encoding=utf-8
set fileencodings=utf-8
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
language messages zh_TW.utf-8

if has('gui_running')
    if has('gui_gtk2') " Linux with GNOME
        set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ 16

    elseif has('gui_macvim') " Mac OS
        set guifont=Menlo\ Regular:h14

    elseif has('gui_win32') " Windows
        set guifont=CodeNewRoman_NF:h16:cANSI:qDRAFT

        " Fix colorscheme do NOT work on Windows
        syntax enable

        " Fix backspace key do NOT work on Windows
        set nocompatible
        set backspace=2
        endif
endif

" Show trailing space after file is written
autocmd BufWritePost * call ShowTrailingSpace()

" Get the cursor position of the previous exit
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
autocmd BufRead * normal zz

" C
autocmd FileType c setlocal foldmethod=expr foldexpr=FoldFunction() foldlevel=1 foldcolumn=4 foldnestmax=1 tabstop=4 tags+=./tags,~/.vim/tags/c
autocmd BufNewFile,BufRead *.h set filetype=header
" autocmd FileType header setlocal syntax=doxygen
autocmd FileType header setlocal syntax=c

" Shell Script
autocmd FileType sh,rc setlocal foldmethod=expr foldexpr=FoldFunction() foldlevel=10 foldcolumn=4 foldnestmax=1 syntax=sh

" Python
autocmd FileType python setlocal foldmethod=indent foldlevel=10 foldcolumn=4 foldnestmax=2 tags+=./tags,~/.vim/tags/python_3_5.tags,~/.vim/tags/python_3_5_pip.tags

" Java
autocmd FileType java setlocal foldmethod=expr foldexpr=FoldFunction() foldlevel=2 foldcolumn=4 foldnestmax=2 tags+=./tags,~/.vim/tags/java_1_8_0.tags

" HTML
autocmd FileType html setlocal foldmethod=indent foldlevel=4 foldcolumn=8 foldnestmax=8

" CSS
autocmd FileType css setlocal foldmethod=marker foldmarker={,} foldlevel=0 foldcolumn=4 foldnestmax=1

" JavaScript
autocmd FileType javascript setlocal foldmethod=expr foldexpr=FoldFunction() foldlevel=1 foldcolumn=4 foldnestmax=2

" Scala
autocmd BufNewFile,BufRead *.scala,*.sc set filetype=scala
" autocmd FileType scala setlocal foldmethod=expr foldexpr=FoldFunction() foldlevel=1 foldcolumn=4 foldnestmax=2

" SQL
autocmd FileType sql setlocal foldmethod=indent foldlevel=10 foldcolumn=4 foldnestmax=2

" HiveQL
autocmd BufNewFile,BufRead *.hql set filetype=hive

" ======== Plugin ========

" -------- 1. Plugin Management --------
" { Vundle }
"

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
filetype plugin indent on

" -------- 2. File Browser --------
" { nerdtree } and { ctrlp }
"

" Show beautiful file browser
Bundle 'scrooloose/nerdtree'
let g:NERDTreeIgnore = [g:ExcludedFileExtension]
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeWinPos = 'right'

" Add icon for different filetype
Bundle 'ryanoasis/vim-devicons'
Bundle 'ryanoasis/vim-webdevicons'

" Fuzzy search of file name
Bundle 'ctrlpvim/ctrlp.vim'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$',
    \ 'file': g:ExcludedFileExtension,
    \ 'link': 'some_bad_symbolic_links',
    \ }
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir']

" -------- 3. Code Structure Analysis --------
" { tagbar }
"

" Show beautiful code structure
Bundle 'majutsushi/tagbar'
let g:tagbar_sort = 0
let g:tagbar_autofocus = 1
" let g:tagbar_autoclose = 1
let g:tagbar_iconchars = ['▸', '▾']
let g:tagbar_left = 1

" Set hot key to jump to/from tag
nnoremap <C-Right> :call MyTargbarShowTag()<CR>
nnoremap <C-Left> <C-t>

" Show structure of h1~h6 in markdown file in tagbar
Bundle 'lvht/tagbar-markdown'

" -------- 4. Syntax/Style/Format Check Framework --------
" { syntastic }
"

" Show checked information of file content
Bundle 'scrooloose/syntastic'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
" let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'

" checkers (https://github.com/vim-syntastic/syntastic/wiki/Syntax-Checkers)
let g:syntastic_c_checkers = ['gcc', 'splint']
let g:syntastic_sh_checkers = ['sh', 'shellcheck']
let g:syntastic_python_checkers = ['python', 'pylint', 'pep8']
let g:syntastic_java_checkers = ['javac']
let g:syntastic_html_checkers = ['tidy']
let g:syntastic_css_checkers = ['csslint']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_json_checkers = ['jsonlint']

" -------- 5. Key Word Search --------
" { ctrlsf } and { vim-man }
"

" Search of key word
Bundle 'dyng/ctrlsf.vim'
let g:ctrlsf_extra_backend_args = {
    \ 'ag': '--ignore tags'
    \}
vmap <C-w> <Plug>CtrlSFVwordExec

" Show man page for key word
Bundle 'vim-utils/vim-man'
" nmap <leader>m <Plug>(Man)
nmap <C-M> <Plug>(Man)

" -------- 6. Status/Tab Line --------
" { airline } and { promptline } and { startify }
"

" Show beautiful status/tab line
Bundle 'vim-airline/vim-airline'
Bundle 'vim-airline/vim-airline-themes'
set laststatus=2
set t_Co=256
let g:airline_theme='badwolf'
let g:airline_powerline_fonts=1
let g:airline#extensions#default#layout = [
    \ ['a', 'b', 'c'],
    \ ['x', 'y', 'z']
    \]
" let g:airline_section_z = airline#section#create(['%3p%%', ' %{g:airline_symbols.linenr}  ', '%l : %c'])
let g:airline_section_z = airline#section#create(['%3p%%', ' | ', '%l : %c'])

" tabline setting
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#exclude_preview = 0

" Modify the seperator
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_left_sep = ' '
let g:airline_left_alt_sep = '|'
let g:airline_right_sep = ' '
let g:airline_right_alt_sep = '|'

" Sync airline style to produce a shell script to beautify bash prompt
Bundle 'edkolev/promptline.vim'
let g:promptline_preset = {
    \'a' : [ '\u', '\h' ],
    \'b' : [ promptline#slices#cwd() ],
    \'c' : [ promptline#slices#vcs_branch(), '$(git rev-parse --short HEAD 2>/dev/null)', promptline#slices#git_status() ],
    \'warn' : [ promptline#slices#python_virtualenv(), promptline#slices#last_exit_code() ]
\}

" Customized vim welcome screen
Bundle 'mhinz/vim-startify'
let g:startify_custom_header =  map(split(system('echo TOUGH GUYS use VIM | cowsay'), '\n'), '"   ". v:val')

" -------- 7. Auto Completion --------
" { YouCompleteMe } and { vim-javacomplete2 } and { tern_for_vim } and { ultisnips }
"

" Auto Completion
if v:version >= 704
    Bundle 'Valloric/YouCompleteMe'
    let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
    let g:ycm_show_diagnostics_ui = 0
    " let g:ycm_semantic_triggers =  {
    " \   'javascript': ['.'],
    " \ }

    " Original (for C++)
    " let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

    " Customized (for C)
    let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/myself/ycm_extra_conf_c.py'

    let g:ycm_server_keep_logfiles = 1
    let g:ycm_serverlog_level = 'debug'
endif

" Auto Completion for Java
Bundle 'artur-shaik/vim-javacomplete2'
autocmd FileType java setlocal omnifunc=javacomplete#Complete
" autocmd FileType java setlocal omnifunc=javacomplete#Complete completefunc=javacomplete#CompleteParamsInf
" let g:JavaComplete_LibsPath = 'C:\Program Files\Java\jdk1.8.0_131\src'
" let g:JavaComplete_UseFQN = 1
" let g:JavaComplete_JavaviDebug = 1
" let g:JavaComplete_JavaviLogfileDirectory = '~/.javacomplete2_serverlog'

" Auto Completion for Javascript
Bundle 'ternjs/tern_for_vim'
" let g:tern_show_signature_in_pum = 1

" Auto completion of code snippet
if v:version >= 704
    Bundle  'SirVer/ultisnips'
    Bundle  'honza/vim-snippets'

    " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
    let g:UltiSnipsExpandTrigger='<tab>'
    let g:UltiSnipsJumpForwardTrigger='<c-b>'
    let g:UltiSnipsJumpBackwardTrigger='<c-z>'

    " If you want :UltiSnipsEdit to split your window.
    " let g:UltiSnipsEditSplit='vertical'
endif

let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']

" -------- 8. Git Integration --------
" { gitv } and { gitgutter } and { nerdtree-git-plugin }
"

" Show git information
Bundle 'tpope/vim-fugitive'
Bundle 'gregsexton/gitv'
let g:Gitv_OpenHorizontal = 1
let g:Gitv_TruncateCommitSubjects=1
cabbrev git Git

" Show add/remove/modify sign in left column
Bundle 'airblade/vim-gitgutter'
" set updatetime=250

" Show git status in nerdtree
Bundle 'Xuyuanp/nerdtree-git-plugin'

" -------- 9. Highlight/Format Code Block Indent --------
" { indentLine } and {vim-autoformat} and { vim-prettier }
"

" Show vertical line in every code block indent
Bundle 'Yggdroot/indentLine'
let g:indentLine_color_term = 239
let g:indentLine_color_gui = '#A9A9A9'
let g:indentLine_color_tty_light = 7
let g:indentLine_color_dark = 1
let g:indentLine_char = '¦'
let g:indentLine_enabled = 0

" Auto change the code indent by defined style for C/C++/Java/Python
Bundle 'Chiel92/vim-autoformat'
let g:autoformat_verbosemode = 1
let g:formatdef_clangformat = '"clang-format -"'
let g:formatters_c = ['clangformat']
let g:formatdef_autopep8 = '"autopep8 -"'
let g:formatters_python = ['autopep8']

" Auto change the code indent by defined style for Javascript/HTML/CSS/JSON
 Bundle 'prettier/vim-prettier'
 let g:prettier#autoformat = 0
 let g:prettier#config#tab_width = 4

" -------- 10. Handle these Paired Signs --------
" { auto-pairs } and { vim-surround } and { matchtag }
"

" Auto complete the paired signs
Bundle 'jiangmiao/auto-pairs'

" Fast modify the paired signs
Bundle 'tpope/vim-surround'

" Highlight the paired HTML tag
Bundle 'gregsexton/matchtag'

" -------- 11. Code Comment --------
" { vim-commentary }
"

" Comment/Decomment lines
Bundle 'tpope/vim-commentary'

" -------- 12. Customization for Language or Filetype --------

" Fast add/modify HTML DOM
Bundle 'mattn/emmet-vim'
" autocmd FileType html,markdown imap <buffer><expr><tab> <sid>Expand_html_tab()
" let g:user_emmet_mode='a'
" let g:user_emmet_complete_tag = 1
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" Auto show the color of code in the backgroud
Bundle 'ap/vim-css-color'

Bundle 'hail2u/vim-css3-syntax'

Bundle 'groenewege/vim-less'

" JavaScript
Bundle 'pangloss/vim-javascript'
let g:javascript_enable_domhtmlcss = 1

" Auto launch web browser to show the markdown file
Bundle 'suan/vim-instant-markdown'

" Produce the Table of Content by h1~h6 of markdown file
Bundle 'mzlogin/vim-markdown-toc'
let g:vmt_auto_update_on_save = 0

" Show screensaver
Bundle 'uguu-org/vim-matrix-screensaver'

highlight LineNr cterm=None ctermfg=grey ctermbg=black guifg=grey guibg=black
highlight CursorLineNr cterm=bold ctermbg=blue guibg=blue
highlight Cursor ctermbg=blue guibg=blue

" Support reStructuredText
Bundle 'Rykka/riv.vim'
Bundle 'gu-fan/InstantRst'
autocmd BufNewFile,BufRead *.rst InstantRst
let project1 = {'path': '~/vimriv/project1',}
let g:riv_projects = [project1]

" Write wiki in vim
Bundle 'vimwiki/vimwiki'

" Switch between paired files defined on .projection.json in the sample project
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-projectionist'

" Highlight docker file
Bundle 'ekalinin/Dockerfile.vim'

" ======== Test ========

Bundle 'mbbill/undotree'
