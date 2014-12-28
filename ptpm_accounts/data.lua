function setUserdata( username, column, data )
	if column and column == "username" then return false end

	local result = executeSQLQuery( "SELECT username FROM users WHERE username = '" .. escapeStr( username ) .. "'" )
	if result then
		if #result <= 0 then
			outputDebugString( "setUserdata: No such username in database 'users': " .. username )
			return false
		end
	end
	
	local sData = tostring( data )
	if sData == "true" then data = "1"
	elseif sData == "false" then data = "0"
	else data = sData
	end
	
	local result = executeSQLQuery( "UPDATE users SET " .. escapeStr( column ) .. " = '" .. escapeStr( data ) .. "' WHERE username = '" .. escapeStr( username ) .. "'" )
	if result then
		return true
	else
		return false
	end
end

function getUserdata( username, column )
	local result = executeSQLQuery( "SELECT username FROM users WHERE username = '" .. escapeStr( username ) .. "'" )
	if result then
		if #result <= 0 then
			outputDebugString( "getUserdata: No such username in database 'users': " .. username )
			return false
		end
	end
	
	if type( column ) == "boolean" and column then -- return all
		local result = executeSQLQuery( "SELECT * FROM users WHERE username = '" .. escapeStr( username ) .. "'" )
		if result then
			-- for i, v in pairs( result[1] ) do
				-- outputChatBox( "Userdata '" .. tostring( i ) .. "' = '" .. tostring( v ) .. "'" )
			-- end
			return result[1]
		end
		return false
	else
		local result = executeSQLQuery( "SELECT " .. escapeStr( column ) .. " FROM users WHERE username = '" .. escapeStr( username ) .. "'" )
		if result then
			return result[1][column]
		end
		return false
	end
end