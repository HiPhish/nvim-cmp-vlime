local cmp = require 'cmp'
local fn = vim.fn
require 'cmp.types.cmp'


-- Converts one fuzzy Vlime completin item to one LSP completion item.
local function fuzzyvlime2lsp(item)
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

-- Converts one simple Vlime completin item to one LSP completion item. See
local function simplevlime2lsp(item)
	return {
		label = item,
		-- kind = ???  Get the kind from Vlime maybe
		-- detail = ???
		-- documentation = '???' Get docstring from Vlime
		-- sortText = ???  Maybe strip earmuffs to ignore in sorting?
		-- textEdit = ???  Maybe downcase the label?
	}
end

---Adapter function which transforms fuzzy completion candidates from Vlime
---into a form suitable for cmp.
local function process_fuzzy_completions(items)
	return vim.tbl_map(fuzzyvlime2lsp, items)
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
	local on_done = function(candiates)
		callback(process_fuzzy_completions(candiates))
	end

	local input = string.sub(params.context.cursor_before_line, params.offset)
	fn['cmp_vlime#get_completion'](input, on_done)
end


-------------------------------------------------------------------------------
cmp.register_source('vlime', source)
