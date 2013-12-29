" insertモードから抜ける
inoremap <silent> jj <ESC>

"----------------------------------------------------
"" neobundle.vim
"----------------------------------------------------
set tabstop=4
set wildmenu
set showcmd
set showmode
set smartcase
set expandtab
set autoindent
set ruler
set visualbell
set t_vb=
set scrolloff=5
set statusline=%F\ [%{strlen(&fenc)?&fenc:'none'}][%{&ff}]%h%y%r%m%=%c,%l/%L
set laststatus=2
set cmdheight=1
set nocompatible
set completeopt=menu,preview
set list
filetype plugin indent off
filetype plugin on
filetype indent on

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'ujihisa/unite-locate'
NeoBundle 'tpope/vim-surround'
NeoBundle 'taglist.vim'
NeoBundle 'ZenCoding.vim'
NeoBundle 'ref.vim'
NeoBundle 'The-NERD-tree'
NeoBundle 'The-NERD-Commenter'
NeoBundle 'fugitive.vim'
NeoBundle 'TwitVim'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-localrc'
NeoBundle 'dbext.vim'
NeoBundle 'rails.vim'
NeoBundle 'Gist.vim'
NeoBundle 'motemen/hatena-vim'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'mattn/unite-advent_calendar'
NeoBundle 'open-browser.vim'
NeoBundle 'ctrlp.vim'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'petdance/vim-perl'
NeoBundle 'hotchpotch/perldoc-vim'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'fuenor/qfixhowm'
NeoBundle 'glidenote/memolist.vim'
NeoBundle 'ack.vim'

" Color Scheme
NeoBundle 'altercation/vim-colors-solarized'
syntax on
if has('gui_running')
  set background=light
else
  set background=dark
endif
colorscheme solarized

" JavaScript
au FileType javascript call JavaScriptFold()

" NerdTree
let file_name = expand("%:p")
if has('vim_starting') && file_name == ""
  autocmd VimEnter * NERDTree ./
endif
nmap <C-e> :NERDTree<Enter>

" Anywhere SID.
function! s:SID_PREFIX()
	return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Set tabline.
function! s:my_tabline() "{{{
	let s = ''
	for i in range(1, tabpagenr('$'))
		let bufnrs = tabpagebuflist(i)
		let bufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears
    let no = i  " display 0-origin tabpagenr.
    let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
    let title = fnamemodify(bufname(bufnr), ':t')
    let title = '[' . title . ']'
    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= no . ':' . title
    let s .= mod
    let s .= '%#TabLineFill# '
  endfor	
	let s .= '%#TabLineFill#%T%=%#TabLine#'
	return s
endfunction "}}}
let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'
set showtabline=2 " 常にタブラインを表示

" The prefix key.
nnoremap    [Tag]   <Nop>
nmap    t [Tag]

" Tab jump
for n in range(1, 9)
	execute 'nnoremap <silent> [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor

map <silent> [Tag]c :tablast <bar> tabnew<CR>
map <silent> [Tag]x :tabclose<CR>
map <silent> [Tag]n :tabnext<CR>
map <silent> [Tag]p :tabprevious<CR>

" neocomplecache
set completeopt=menuone
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_max_list = 20
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_dictionary_filetype_lists = {
  \ 'default' : '',
  \ 'perl'    : $HOME . '/.vim/dict/perl.dict' 
  \ }
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()
inoremap <expr><TAB> pumvisible() ? "\<Down>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<Up>" : "\<S-TAB>"
inoremap <expr><C-y> neocomplcache#close_popup()

" perl syntax
autocmd BufNewFile,BufRead *.psgi	set filetype=perl
autocmd BufNewFile,BufRead *.t    set filetype=perl

" momolist
nmap <Leader>mn :MemoNew<Enter>
nmap <Leader>ml :MemoList<Enter>
nmap <Leader>mg :MemoGrep<Enter>
