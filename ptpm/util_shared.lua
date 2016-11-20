-- returns a table from data that looks like this: "26,150;31,400;37,300"
function commaPairedStringToTable(str)
	local explodedTable = {}

	if not str or #str == 0 then
		return explodedTable
	end
	
	tokens = split(str, string.byte(';'))
	
	if tokens then
		for i, pair in ipairs(tokens) do
			local first = gettok(pair, 1, 44)
			local second = gettok(pair, 2, 44)

			if tonumber(first) then
				first = tonumber(first)
			end

			if tonumber(second) then
				second = tonumber(second)
			end

			explodedTable[i] = {first, second}
		end
	end

	return explodedTable
end


function weaponListToString(weapons, includeAmmo)
	if #weapons == 0 then
		return "- No Weapons -"
	end

	local str = ""

	for i, pair in ipairs(weapons) do
		if pair[1] and pair[2] and pair[1] ~= 0 and pair[2] ~= 0 then
			if #str > 0 then
				str = str .. "\n"
			end

			str = str .. getWeaponNameFromID(pair[1])

			if includeAmmo then
				str = str .. " (" .. tostring(pair[2]) .. ")"
			end
		end
	end

	return str
end