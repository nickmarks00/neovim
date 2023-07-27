" UltiSnips Snippet keys
let g:UltiSnipsExpandTrigger = "<Tab>"
let g:UltiSnipsJumpForwardTrigger = "jk"
let g:UltiSnipsJumpBackwardTrigger = "kj"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']

nnoremap <leader>U :call UltiSnips#RefreshSnippets()<CR>
