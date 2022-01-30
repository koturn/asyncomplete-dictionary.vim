Dictionary source for asyncomplete.vim
======================================

Provide words in `'dictionary'` autocompletion source for [prabirshrestha/asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim "prabirshrestha/asyncomplete.vim")


## Installation

### With [dein.vim](https://github.com/Shougo/dein.vim "Shougo/dein.vim")

#### With TOML configulation file

Write following text to your TOML configulation file of [dein.vim](https://github.com/Shougo/dein.vim "Shougo/dein.vim") and execute `:call dein#install()`. in your Vim.

```vim
[[plugins]]
repo = 'koturn/asyncomplete-dictionary.vim'
hook_add = '''
autocmd User asyncomplete_setup call asyncomplete#register_source(
      \ asyncomplete#sources#dictionary#get_source_options({
      \   'name': 'dictionary',
      \   'allowlist': ['*'],
      \   'completor': function('asyncomplete#sources#dictionary#completor')
      \ }))
'''
```

#### Without TOML configulation file

Write following code to your `.vimrc` and execute `:call dein#install()` in your Vim.

```vim
call dein#add('koturn/asyncomplete-dictionary.vim', {
      \ 'hook_add': join([
      \   'autocmd User asyncomplete_setup call asyncomplete#register_source(',
      \   'asyncomplete#sources#dictionary#get_source_options({',
      \     "'name': 'dictionary',",
      \     "'allowlist': ['*'],",
      \     "'completor': function('asyncomplete#sources#dictionary#completor')"
      \   }), ' ')
      \ ], "")
      \})
```

### With [vim-plug](https://github.com/junegunn/vim-plug "junegunn/vim-plug")

Write following code to your `.vimrc` and execute `:PlugInstall` in your Vim.

```vim
Plug 'koturn/vim'
```

### With [vim-pathogen](https://github.com/tpope/vim-pathogen "tpope/vim-pathogen")

Clone this repository to the package directory of pathogen.

```shell
$ git clone https://github.com/koturn/asyncomplete-dictionary.vim ~/.vim/bundle/vim
```

### With packages feature

In the first, clone this repository to the package directory.

```shell
$ git clone https://github.com/koturn/asyncomplete-dictionary.vim ~/.vim/pack/koturn/opt/vim
```

Second, add following code to your `.vimrc`.

```vim
packadd asyncomplete-dictionary.vim
```

### With manual

If you don't want to use plugin manager, put files and directories on
`~/.vim/`, or `%HOME%/vimfiles/` on Windows.


## Registration

```vim
autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#dictionary#get_source_options({
      \ 'name': 'dictionary',
      \ 'allowlist': ['*'],
      \ 'completor': function('asyncomplete#sources#dictionary#completor'),
      \ }))
```


### Options

Cache level.

```vim
let g:asyncomplete_dictionary_cache_level = 2
```

Cache Level   | Description
--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
`0`           | Parse all dictionaries specifiled in global and local `'dictionary'` every time.
`1` (Default) | Parse all dictionaries specifiled in global and local `'dictionary'` on the first time and cache the words. Don't remake cache as long as global or local value of `'dictionary'` is not updated, or dictionary files is not changed, deleted or created.
`2`           | Parse all dictionaries specifiled in global and local `'dictionary'` on the first time and cache the words. Don't remake cache.


## Required plugins

- [prabirshrestha/asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim "prabirshrestha/asyncomplete.vim")


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE "LICENSE").
