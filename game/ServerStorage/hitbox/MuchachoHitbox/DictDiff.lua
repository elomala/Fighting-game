local module = {}

local function find(a, tbl)
	for _, a_ in ipairs(tbl) do 
		if a_==a then return true end 
	end
end

function module.difference(a, b)
	local ret = {}
	for _, v in ipairs(a) do
		if not find(v,b) then table.insert(ret, v) end
	end
	
	return ret
end


return module

