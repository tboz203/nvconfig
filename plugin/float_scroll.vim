" vim: ft=vim

function s:float_scroll(forward)
  let key = a:forward ? "\<C-f>" : "\<C-b>"
  let winnr = winnr()
  for i in range(1, winnr('$'))
    if getwinvar(i, 'float')
      return i."\<C-w>w".key."\<C-w>p"
    endif
  endfor
  return ""
endfunction

command -nargs=0 FloatScrollForwards call s:float_scroll(v:true)
command -nargs=0 FloatScrollBackwards call s:float_scroll(v:false)

noremap <C-n> <cmd>FloatScrollForwards<cr>
noremap <C-p> <cmd>FloatScrollBackwards<cr>
