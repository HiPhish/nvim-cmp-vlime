local cmp = require 'cmp'
local lsp_types = require 'cmp.types.lsp'
local fn = vim.fn
require 'cmp.types.cmp'

---Maps a Swank flag character to an LSP CompletionItemKind
local flag_to_kind = {
	b = lsp_types.CompletionItemKind.Variable,
	f = lsp_types.CompletionItemKind.Function,
	g = lsp_types.CompletionItemKind.Method,
	c = lsp_types.CompletionItemKind.Class,
	t = lsp_types.CompletionItemKind.Class,
	m = lsp_types.CompletionItemKind.Operator,
	s = lsp_types.CompletionItemKind.Operator,
	p = lsp_types.CompletionItemKind.Module,
}

---Precedence of LSP kinds for display in descending order
local kind_precedence = {
	lsp_types.CompletionItemKind.Module,
	lsp_types.CompletionItemKind.Class,
	lsp_types.CompletionItemKind.Operator,
	lsp_types.CompletionItemKind.Method,
	lsp_types.CompletionItemKind.Function,
	lsp_types.CompletionItemKind.Variable,
}

---Converts a flags string to one LSP kind object
---@param flags string  The flags string as provided by Vlime
---@return number? kind  The LSP kind or nil if no flags
local function flags_to_kind(flags)
	local kinds = {}  -- This is used as a set
	for i = 1, #flags do
		local kind = flag_to_kind[flags:sub(i, i)]
		if kind then kinds[kind] = true end
	end
	-- A symbol may have many flags, which map onto different kinds. The kind
	-- precedence tells us which of the kinds to display; we pick the highest
	-- kind we can find.
	for _, kind in ipairs(kind_precedence) do
		if kinds[kind] then return kind end
	end
end

---Set the documentation of an LSP completion item to the docstring of the
---symbol.
---@param item table  The LSP completion item to mutate
---@return nil
local function set_documentation(item)
	local symbol = item.label
	local callback = function(docstring)
		item.documentation = docstring
	end
	fn['cmp_vlime#get_documentation'](symbol, callback)
end

-- Converts one fuzzy Vlime completion item to one LSP completion item.
local function fuzzy2lsp(item)
	local symbol = item[1]
	local flags  = item[4]
	return {
		label = symbol,
		labelDetails = {
			detail = flags,
		},
		kind = flags_to_kind(flags) or lsp_types.CompletionItemKind.Keyword,
		-- detail = 'some detail',  -- Perhaps the symbol package?
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

---@param item table  The LSP completion item to mutate
---@param callback function
function source:resolve(item, callback)
	set_documentation(item)
	vim.defer_fn(callback(item), 5)
end

-------------------------------------------------------------------------------
cmp.register_source('vlime', source)

-- vim:tw=79:ts=4:sw=4:noet:
