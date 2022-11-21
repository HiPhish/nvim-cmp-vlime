local cmp = require 'cmp'
local fn = vim.fn
require 'cmp.types.cmp'


-- Converts one fuzzy Vlime completion item to one LSP completion item.
local function fuzzy2lsp(item)
	return {
		label = item[1],
		labelDetails = {
			detail = item[4],
		},
		-- kind = ???  Get the kind from the last item field
		-- detail = ???
		-- documentation = '???' Get docstring from Vlime
		-- sortText = ???  Maybe strip earmuffs to ignore in sorting?
		-- textEdit = ???  Maybe downcase the label?
	}
end

-- Converts one simple Vlime completion item to one LSP completion item.
local function simple2lsp(item)
	return {
		label = item,
		-- kind = ???  Get the kind from Vlime maybe
		-- detail = ???
		-- documentation = '???' Get docstring from Vlime
		-- sortText = ???  Maybe strip earmuffs to ignore in sorting?
		-- textEdit = ???  Maybe downcase the label?
	}
end


-------------------------------------------------------------------------------
local source = {}

---Source is only available if Vlime is connected
function source:is_available()
	local connection = vim.fn['vlime#connection#Get'](true)
	return connection ~= vim.NIL
end

function source:get_debug_name()
	return 'CMP Vlime'
end

function source:get_keyword_pattern()
	return [[\k\+]]
end

---Invoke completion (required).
---@param callback function
function source:complete(params, callback)
	local fuzzy = params.option.fuzzy or false

	local on_done = function(candidates)
		local mapper = fuzzy and fuzzy2lsp or simple2lsp
		callback(vim.tbl_map(mapper, candidates or {}))
	end

	local input = string.sub(params.context.cursor_before_line, params.offset)
	local getter = fuzzy and 'cmp_vlime#get_fuzzy_completion' or 'cmp_vlime#get_simple_completion'
	fn[getter](input, on_done)
end


-------------------------------------------------------------------------------
cmp.register_source('vlime', source)
