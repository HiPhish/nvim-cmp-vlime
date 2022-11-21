" All interaction with the Vlime API has to be in Vim script, hence why we
" have these thin shims.


function cmp_vlime#get_fuzzy_completion(base, callback)
	silent let l:connection = vlime#connection#Get(v:true)
	call l:connection.FuzzyCompletions(a:base, {c, r -> luaeval('_A[1](_A[2])', [a:callback, r[0]])})
endfunction

function cmp_vlime#get_simple_completion(base, callback)
	silent let l:connection = vlime#connection#Get(v:true)
	call l:connection.SimpleCompletions(a:base, {c, r -> luaeval('_A[1](_A[2])', [a:callback, r[0]])})
endfunction
