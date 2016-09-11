local playerStats = {}

function loadPlayerStats( thePlayer, username )
	-- Load stats to 'playerstats' table
	playerStats[thePlayer] = {}
	
	local result = executeSQLQuery( "SELECT * FROM playerstats WHERE username = '" .. escapeStr( username ) .. "'" )
	if result then
		for i, v in pairs( result[1] ) do
			if tonumber( v ) ~= nil then
				playerStats[thePlayer][i] = tonumber( v )
			else
				playerStats[thePlayer][i] = v
			end
			-- outputChatBox( "Stats '" .. tostring( i ) .. "' = '" .. tostring( v ) .. "'" )
		end
		return true
	end
	return false
end

function unloadPlayerStats( thePlayer )
	playerStats[thePlayer] = nil
end

function savePlayerStats( thePlayer, username )
	if not username or not playerStats[thePlayer] then return false end
	
	local updateStr = ""
	for column, data in pairs( playerStats[thePlayer] ) do    
		if doesColumnExistOnDatabase( "playerstats", column ) and column ~= "username" then
			local sData = tostring( data )
			if sData == "true" then data = "1"
			elseif sData == "false" then data = "0"
			else data = sData
			end
			
			updateStr = updateStr .. escapeStr( column ) .. " = '" .. escapeStr( sData ) .. "', "
		end
	end
	
	local result = executeSQLQuery( "UPDATE playerstats SET " .. string.sub(updateStr, 1, -3) .. "WHERE username = '" .. escapeStr( username ) .. "'" )
	if result then
		return true
	else
		return false
	end
end

function getPlayerStats( thePlayer )
	if playerStats[thePlayer] then
		return playerStats[thePlayer]
	end
	return false
end

function setPlayerStatistic( thePlayer, data, value )
	local username = getSensitiveUserdata( thePlayer, "username" )
	if not username then return false end
	
	if playerStats[thePlayer] then
		if playerStats[thePlayer][data] ~= nil then
			playerStats[thePlayer][data] = value
			return true
		end
	end
	return false
end

function getPlayerStatistic( thePlayer, data )
	local username = getSensitiveUserdata( thePlayer, "username" )
	if not username then return false end
	
	if playerStats[thePlayer] then
		return playerStats[thePlayer][data]
	end
	return false
end