title: 我的nvim配置
date: 2019-10-719 16:00:00
tags:
    - nvim
---

### 我的nvim配置

一步步搭的，还是蛮好看的O(∩_∩)O

```
scriptencoding utf-8
set encoding=utf-8

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
" tab栏标志(airline插件)
let g:airline#extensions#tabline#enabled = 1
" 主题（airline)
let g:airline_theme='bubblegum'
" oceanic 主题
if (has("termguicolors"))
 set termguicolors
endif


" 插件管理器
" set nocompatible
" filetype off

" set rtp+=~/.vim/bundle/Vundle.vim

:call plug#begin('~/.local/share/nvim/plugged')
Plug 'VundleVim/Vundle.vim'

" 主题色及代码高亮
" Plug 'liuchengxu/space-vim-theme'
" Plug 'lifepillar/vim-solarized8'
" Plug 'altercation/vim-colors-solarized'
Plug 'mhartington/oceanic-next'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'HerringtonDarkholme/yats.vim'

" 动作栏
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" 功能插件

" 符号对齐
Plug 'junegunn/vim-easy-align'
" 代码自动提示
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-tsserver', {'branch': 'release'}
Plug 'neoclide/coc-css', {'branch': 'release'}
Plug 'neoclide/coc-highlight', {'branch': 'release'}
Plug 'neoclide/coc-html', {'branch': 'release'}
" 输入法切换
Plug 'https://github.com/vim-scripts/fcitx.vim.git'
" 文件搜索
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
Plug 'junegunn/fzf.vim' 
" 侧边栏
Plug 'scrooloose/nerdtree'
call plug#end()
filetype plugin indent on

" 键映射
nnoremap <silent> <C-p> :Files<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-e> :Buffers<CR>
map <C-g> :GFiles<CR>
let g:fzf_action = { 'ctrl-e': 'edit' }

autocmd StdinReadPre * let s:std_in=1 autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" syntax enable
" set background=dark
" colorscheme solarized8
" colorscheme space_vim_theme
syntax on
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
colorscheme OceanicNext

" vim变量配置

" 当前行高亮
set cursorline
" 行号配置
set number
set relativenumber
set showmode
set smartcase

" 支持tab移动选择
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" tab缩进
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab
set smarttab

" 自动缩进
set autoindent
set smartindent
```
