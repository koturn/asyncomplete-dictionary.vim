let s:DEFAULT_CACHE_LEVEL = 1

function! asyncomplete#sources#dictionary#get_source_options(opt) " {{{
  return a:opt
endfunction " }}}

function! asyncomplete#sources#dictionary#completor(opt, ctx) abort " {{{
  let candidates = s:gather_candidates()
  let startcol = a:ctx.col - len(matchstr(a:ctx.typed, '\w\+$'))
  call asyncomplete#complete(a:opt.name, a:ctx, startcol, candidates)
endfunction " }}}


function! s:_gather_candidates2() abort " {{{
  let cache_level = get(g:, 'asyncomplete_dictionary_cache_level', s:DEFAULT_CACHE_LEVEL)
  if cache_level > 1
    if !exists('b:asyncomplete_dictionary_candidates')
      let b:asyncomplete_dictionary_candidates = s:words2candidates(s:flatten(map(s:get_dict_filepath_list(), 's:read_dictionary(v:val)')))
      call asyncomplete#log('asyncomplete#sources#dictionary' 'Cache updated [2]')
    endif
    return b:asyncomplete_dictionary_candidates
  elseif cache_level > 0
    let dict_file_info = map(s:get_dict_file_info(), 'extend(v:val, {"newftime": getftime(v:key)})')
    let diff_dict_file_info = map(filter(copy(dict_file_info), 'v:val.ftime != v:val.newftime'), '{"ftime": v:val.newftime, "words": s:read_dictionary(v:key)}')
    if !empty(diff_dict_file_info) || !exists('b:asyncomplete_dictionary_candidates')
      let b:asyncomplete_dictionary_candidates = s:words2candidates(s:flatten(map(values(extend(dict_file_info, diff_dict_file_info)), 'v:val.words')))
      call asyncomplete#log('asyncomplete#sources#dictionary' 'Cache updated [1]')
    endif
    return b:asyncomplete_dictionary_candidates
  else
    return s:words2candidates(s:flatten(map(s:get_dict_filepath_list(), 's:read_dictionary(v:val)')))
  endif
endfunction " }}}


if exists('##OptionSet') " {{{
  let s:gather_candidates = function('s:_gather_candidates2')
else
  function! s:_gather_candidates1() abort " {{{
    if get(s:, 'old_opt_dictionary') isnot# &g:dictionary || get(b:, 'asyncomplete_dictionary_old_opt_dictionary') isnot# &l:dictionary
      call s:on_option_dictionary_set()
      let [s:old_opt_dictionary, b:asyncomplete_dictionary_old_opt_dictionary] = [&g:dictionary, &l:dictionary]
    endif
    return s:_gather_candidates2()
  endfunction " }}}
  let s:gather_candidates = function('s:_gather_candidates1')
endif " }}}

function! s:words2candidates(words) abort " {{{
  if get(g:, 'asyncomplete_dictionary_sort_required', 1)
    call uniq(sort(a:words))
  endif
  return map(a:words, '{"word": v:val, "dup": 1, "icase": 1, "menu": "[dict]"}')
endfunction " }}}

function! s:read_dictionary(filepath) abort " {{{
  return filereadable(a:filepath) ? s:flatten(map(readfile(a:filepath), 'split(v:val, "\\s\\+")')) : []
endfunction " }}}

function! s:get_dict_file_info() abort " {{{
  if !exists('b:asyncomplete_dictionary_dict_file_info')
    let b:asyncomplete_dictionary_dict_file_info = {}
    for filepath in s:get_dict_filepath_list()
      let b:asyncomplete_dictionary_dict_file_info[filepath] = {'ftime': 0, 'words': []}
    endfor
  endif
  return b:asyncomplete_dictionary_dict_file_info
endfunction " }}}

function! s:get_dict_filepath_list() abort " {{{
  return uniq(sort(filter(map(split(&g:dictionary, '\\\@<!,') + split(&l:dictionary, '\\\@<!,'), 'expand(substitute(v:val, "\\,", ",", "g"))'), 'filereadable(v:val)')))
endfunction " }}}

function! s:on_option_dictionary_set() abort " {{{
  let cache_level = get(g:, 'asyncomplete_dictionary_cache_level', s:DEFAULT_CACHE_LEVEL)
  if cache_level != 1
    return
  endif
  for b in map(v:option_type ==# 'local' ? getbufinfo(expand('<abuf>')) : getbufinfo(), 'v:val.variables')
    silent! unlet b.asyncomplete_dictionary_dict_file_info
    silent! unlet b.asyncomplete_dictionary_candidates
  endfor
endfunction " }}}

if exists('*flatten')
  let s:flatten = function('flatten')
else
  function! s:_flatten(list, ...) abort " {{{
    let limit = a:0 > 0 ? a:1 : -1
    if limit == 0
      return a:list
    endif
    let memo = []
    let limit -= 1
    for Value in a:list
      let memo += type(Value) == v:t_list ? s:_flatten(Value, limit) : [Value]
      unlet! Value
    endfor
    return memo
  endfunction " }}}
  let s:flatten = function('s:_flatten')
endif


if exists('##OptionSet')
  " OptionSet has been supported since Vim 8.1.1542.
  augroup AsyncompleteDictionary " {{{
    autocmd!
    autocmd OptionSet dictionary call s:on_option_dictionary_set()
  augroup END " }}}
endif
