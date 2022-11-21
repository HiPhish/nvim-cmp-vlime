function cmp_vlime#get_completion(base, callback)
	silent let l:connection = vlime#connection#Get(v:true)
	call l:connection.FuzzyCompletions(a:base, {c, r -> luaeval('_A[1](_A[2])', [a:callback, r[0]])})
endfunction
