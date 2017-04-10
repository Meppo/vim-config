" Last change:	2017/04/03
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" Environment {{{

    " When started as "evim", evim.vim will already have done these settings.
    if v:progname =~? "evim"
      finish
    endif

    " Identify platform {
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return  (has('win32') || has('win64'))
        endfunction
    " }

    " Basics {
        set nocompatible        " Must be first line
        if !WINDOWS()
            set shell=/bin/sh
        endif
    " }

    " Windows Compatible {
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if WINDOWS()
          set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
        endif
    " }
    
    " Arrow Key Fix {
        " https://github.com/spf13/spf13-vim/issues/780
        if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
            inoremap <silent> <C-[>OC <RIGHT>
        endif
    " }

" }}}

" General {{{

    set background=dark         " Assume a dark background

    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8
    set fileencodings=ucs-bom,utf-8,cp936,gbk,gb2312,gb18030,big5

    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    "set virtualedit=onemore             " Allow for cursor beyond last character
    set history=50                      " Store a ton of history (default is 20)
    "set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator

    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " Restore cursor to file position in previous editing session
    function! ResCur()
            if line("'\"") <= line("$")
                silent! normal! g`"
                return 1
            endif
    endfunction

    augroup resCur
        autocmd!
        autocmd BufWinEnter * call ResCur()
    augroup END

    if has("vms")
      set nobackup		" do not keep a backup file, use versions instead
    else
       set backup		" keep a backup file
       set backupdir=/tmp/
    endif
" }}}

" Vim UI {{{

    set tabpagemax=15               " Only show 15 tabs
    set showmode                    " Display the current mode
    set cursorline                  " Highlight current line

    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr    " Remove highlight color from current line number

    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    ""if has('statusline')
    ""    set laststatus=2

    ""    " Broken down into easily includeable segments
    ""    set statusline=%<%f\                     " Filename
    ""    set statusline+=%w%h%m%r                 " Options
    ""    if !exists('g:override_spf13_bundles')
    ""        set statusline+=%{fugitive#statusline()} " Git Hotness
    ""    endif
    ""    set statusline+=\ [%{&ff}/%Y]            " Filetype
    ""    set statusline+=\ [%{getcwd()}]          " Current dir
    ""    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    ""endif
    augroup statusline
        autocmd!
        autocmd FileType * :setlocal statusline=%F
        autocmd FileType * :setlocal statusline+=[%n]
        autocmd FileType * :setlocal statusline+=%=
        autocmd FileType * :setlocal statusline+=%l
        autocmd FileType * :setlocal statusline+=,
        autocmd FileType * :setlocal statusline+=%c-%v
        autocmd FileType * :setlocal statusline+=\ 
        autocmd FileType * :setlocal statusline+=%p%%
    augroup END

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" }}}

" Formatting {{{
    "set nowrap                      " Do not wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks

    " Remove trailing whitespaces and ^M chars
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:spf13_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif

    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " preceding line best in a plugin but here for now.

    autocmd BufNewFile,BufRead *.coffee set filetype=coffee

    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell
" }}}

" Key (re)Mappings {{{

    " Set mapleader
    let mapleader=","
    let maplocalleader=","

    " new window open file $VIMRC  
    nnoremap <localleader>ev :split ~/.vimrc<cr>
    " reload $VIMRC's configure
    nnoremap <localleader>sv :source ~/.vimrc<cr>

    " jump in multi windows
    noremap <C-J>     <C-W>j
    noremap <C-K>     <C-W>k
    noremap <C-H>     <C-W>h
    noremap <C-L>     <C-W>l

    " change the window size
    nmap w= :resize +3<CR>
    nmap w- :resize -3<CR>
    nmap w, :vertical resize -3<CR>
    nmap w. :vertical resize +3<CR>

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " Yank from the cursor to the end of the line, to be consistent with C and D.
    nnoremap Y y$

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " toggle search highlighting 
    nnoremap <localleader>/ :nohlsearch<cr>

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    vnoremap . :normal .<CR>

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip

    " Ctrl+d delete a line in insert mode
    inoremap <c-d> <esc>ddi
    " Ctrl+u convert the word(cursor at) to uppercase in insert mode
    inoremap <c-u> <esc>ebgUwea

    " create abbreviation: -- ywjssig => my email
    iabbrev ywjssig -- <cr>WenJin Yang<cr>yang.wenjin1234@qq.com

    " add " for word
    nnoremap <localleader>" viw<esc>a"<esc>hbi"<esc>lel
    inoremap <localleader>' <esc>ebea"<esc>hbi"<esc>lela
    vnoremap <localleader>" iw<esc>a"<esc>hbi"<esc>lel

    " highlight extra space
    highlight Error ctermbg=red guibg=red
    nnoremap <localleader>w :match Error /\v {2,}/<cr>
    nnoremap <localleader>W :match none<cr>


    " for grep
    "nnoremap <localleader>g :silent execute "grep! -R " . shellescape(expand("<cWORD>")) . " ."<cr>:copen 5<cr>
    "nnoremap <localleader>n :cnext<cr>
    "nnoremap <localleader>p :cprevious<cr>
" }}}

" Vundle settings {{{

" vundle download url:
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tomasr/molokai' " 配色
Plugin 'vim-scripts/winmanager' " 多窗口管理插件 :wm
Plugin 'vim-scripts/minibufexpl.vim' "顶部buffer列表插件
Plugin 'vim-scripts/taglist.vim'  " 左边ctag函数列表
Plugin 'vim-scripts/genutils'     " lookupfile 依赖插件
Plugin 'eikenb/acp'               " 自动补全插件
Plugin 'vim-scripts/AutoClose'    " 自动补全另一边括号 引号等插件
Plugin 'vim-scripts/snipper'      " 识别不同类型语言的关键字语法插件
Plugin 'kien/ctrlp.vim'   " 快速搜索文件工具

" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'lookupfile.vim'

" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
"Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" }}}
"

" Plugins {{{

    " taglist settings {
        let Tlist_Show_One_File=1
        let Tlist_Exit_OnlyWindow=1
    " }

    " WinManager settings ----------- {
        let g:winManagerWindowLayout='FileExplorer|TagList'
        nmap wm :WMToggle<cr>
    " }

    " ctrlp settings ----------- {
        " 使用 ctrl+p 开始查找
        let g:ctrlp_map = '<c-p>'
        let g:ctrlp_by_filename = 1
        " 设置查找根目录时, 优先找到.svn .git这种根目录, 没有则设置成文件当前目录
        let g:ctrlp_working_path_mode = 'ra'
        " 不设置最大文件扫描数目限制
        let g:ctrlp_max_files = 0
        " 退出VIM时不删除缓存文件,缓存文件g:ctrlp_cache_dir=$HOME.'/.cache/ctrlp'
        let g:ctrlp_clear_cache_on_exit = 0
        " 显示并查找隐藏文件
        let g:ctrlp_show_hidden = 1
        " <c-y>建立新的空文档时 在当前窗口显示
        let g:ctrlp_open_new_file = 'r'
        " <c-z> <c-o>找开多个文件时 窗口的显示
        let g:ctrlp_open_multiple_files = 'jr'
    " }

    " cscope settings ----------- {
        set cscopequickfix=s-,c-,d-,i-,t-,e-
        "查找声明
        map ,ss :cs find s <C-R>=expand("<cword>")<CR><CR>
        "查找定义
        map ,sg :cs find g <C-R>=expand("<cword>")<CR><CR>
        "查找调用
        map ,sc :cs find c <C-R>=expand("<cword>")<CR><CR>
        "查找指定字符串
        map ,st :cs find t <C-R>=expand("<cword>")<CR><CR>
        "查找egrep模式
        map ,se :cs find e <C-R>=expand("<cword>")<CR><CR>
        "查找文件
        map ,sf :cs find f <C-R>=expand("<cfile>")<CR><CR>
        "查找包含本文件的文件
        map ,si :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
        "查找本函数调用的函数
        map ,sd :cs find d <C-R>=expand("<cword>")<CR><CR>
        map ,vss :scs find s <C-R>=expand("<cword>")<CR><CR>
        map ,vsg :scs find g <C-R>=expand("<cword>")<CR><CR>
        map ,vsc :scs find c <C-R>=expand("<cword>")<CR><CR>
        map ,vst :scs find t <C-R>=expand("<cword>")<CR><CR>
        map ,vse :scs find e <C-R>=expand("<cword>")<CR><CR>
        map ,vsf :scs find f <C-R>=expand("<cfile>")<CR><CR>
        map ,vsi :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
        map ,vsd :scs find d <C-R>=expand("<cword>")<CR><CR>


        " tag auto switch  ----------- {{{
        function! TagAutoSwitch1()
            let tags_pre_dir=expand($HOME . '/vim_tags_dir/')

            " __PROJECTLIST_SED_BEGIN__
            let project_dicts = {
                \'MY_PROJECT1': '/opt/work/MY_PROJECT1',
            \}
            " __PROJECTLIST_SED_END__

            let _name = fnamemodify(bufname("%"), ":p:h")
            if LINUX()
                let path_components = split(_name, '/')
            elseif WINDOWS()
                let path_components = split(_name, '\\')
            else
                return 0
            endif

            for project_name in keys(project_dicts)
                if count(path_components, project_name)
                    let tag_str = tags_pre_dir . project_name . "/tags"
                    let cscope_str = tags_pre_dir . project_name . "/cscope.out"
                    exe 'set tags='.tag_str
                    
                    if cscope_connection(1, project_name)
                        " echom "already connect " . project_name . "'cscope.out!"
                    else
                        exe 'cs reset'
                        exe 'set nocsverb'
                        exe 'cs add ' . cscope_str . " " . project_dicts[project_name]
                        exe 'cd ' . project_dicts[project_name]
                    endif

                    " ignore the file no suffix or suffix with .c/h file like
                    "   MAKEFILE, MODEL, test.gif and so on
                    let g:ctrlp_custom_ignore = {
                            \ 'dir':  '\v[\/]\.(git|hg|svn)$',
                            \ 'file': '\v(\.[^ch]|[^.]\w$)',
                            \ }
                endif
            endfor
        endfunction
        autocmd BufEnter *.[ch] :call TagAutoSwitch1()
    " }

    " miniBufexpl.vim settings ----------- {
        let g:miniBufExplMapCTabSwitchBufs=1
        let g:miniBufExplMapWindowNavVim=1
        let g:miniBufExplSplitBelow=0
        let g:miniBufExplModSelTarget = 1
    " }

" }}}

" GUI Settings {{{


    " set color
    if has("gui_running")
        colorscheme molokai
        set guioptions-=T           " Remove the toolbar
        set lines=40                " 40 lines of text instead of 24
        if LINUX() && has("gui_running")
            set guifont=Bitstream\ Vera\ Sans\ Mono\ 12
        elseif OSX() && has("gui_running")
            set guifont=Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
        elseif WINDOWS() && has("gui_running")
            set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
        endif
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        endif
        "set term=builtin_ansi       " Make arrow and other keys work
    endif

" }}}

" Functions {{{

    " Initialize directories {
    function! InitializeDirectories()
        let parent = $HOME
        let prefix = 'vim'
        let dir_list = {
                    \ 'backup': 'backupdir',
                    \ 'views': 'viewdir',
                    \ 'swap': 'directory' }

        if has('persistent_undo')
            let dir_list['undo'] = 'undodir'
        endif

        " To specify a different directory in which to place the vimbackup,
        " vimviews, vimundo, and vimswap files/directories, add the following to
        " your .vimrc.before.local file:
        "   let g:spf13_consolidated_directory = <full path to desired directory>
        "   eg: let g:spf13_consolidated_directory = $HOME . '/.vim/'
        if exists('g:spf13_consolidated_directory')
            let common_dir = g:spf13_consolidated_directory . prefix
        else
            let common_dir = parent . '/.' . prefix
        endif

        for [dirname, settingname] in items(dir_list)
            let directory = common_dir . dirname . '/'
            if exists("*mkdir")
                if !isdirectory(directory)
                    call mkdir(directory)
                endif
            endif
            if !isdirectory(directory)
                echo "Warning: Unable to create backup directory: " . directory
                echo "Try: mkdir -p " . directory
            else
                let directory = substitute(directory, " ", "\\\\ ", "g")
                exec "set " . settingname . "=" . directory
            endif
        endfor
    endfunction
    "call InitializeDirectories()
    " }

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }

    " Shell command {
    function! s:RunShellCommand(cmdline)
        botright new

        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nowrap
        setlocal filetype=shell
        setlocal syntax=shell

        call setline(1, a:cmdline)
        call setline(2, substitute(a:cmdline, '.', '=', 'g'))
        execute 'silent $read !' . escape(a:cmdline, '%#')
        setlocal nomodifiable
        1
    endfunction

    command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
    " e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %
    " }

" }}}

" Vimscript file setting ----------------------------- {{{
augroup filetype_vim
    autocmd FileType vim :setlocal foldmethod=marker
augroup END
" }}}

