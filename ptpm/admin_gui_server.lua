verifySerials = true
verifyCommunity = false



function banCommand( thePlayer, victimName, reason )
	if not isPlayerOp( thePlayer ) then return end
	
	if victimName then
		-- strip spaces from the name
		victimName = victimName:gsub(" ","")	
	end
	
	local victimPlayer = getPlayerFromNameSection( victimName )
	if victimPlayer == nil then
		return outputChatBox( "Usage: /ban <person> [<reason>]", thePlayer, unpack( colour.personal ) )
	elseif victimPlayer == false then
		return outputChatBox( "Too many matches for name '" .. victimName .. "'", thePlayer, unpack( colour.personal ) )
	elseif victimPlayer == thePlayer then
		return outputChatBox( "You can't ban yourself!", thePlayer, unpack( colour.personal ) )
	end
	
	local playerName = getPlayerName( thePlayer )
	victimName = getPlayerName( victimPlayer )
	local text = victimName .. " was banned from the server by " .. playerName
--	local reason = table.concat( {...}, " " )
	if reason ~= "" then text = text .. " (" .. reason .. ")" end
	local ip = getPlayerIP( victimPlayer )

	local result
	if verifySerials then
		result = banPlayer( victimPlayer, true, false, true , thePlayer, reason ~= "" and reason or nil, 172800 )
	elseif verifyCommunity then
		result = banPlayer( victimPlayer, true, true, true , thePlayer, reason ~= "" and reason or nil, 172800 )
	else
		result = banPlayer( victimPlayer, true, false, false, thePlayer, reason ~= "" and reason or nil, 172800 )
	end
	
	if result then 
		outputChatBox( text .. ".", root, unpack( colour.global ) )
	else 
		outputChatBox( "Banning " .. victimName .. " failed.", thePlayer, unpack( colour.personal ) )
	end
end
addCommandHandler( "ban", function(player,command,name,... )
	local reason = table.concat( {...}, " " )
	banCommand(player,name,reason)
end)


addEvent("serverBanPlayer",true)
addEventHandler("serverBanPlayer",root,
	function(banText)
		if banText and banText ~= "" then
			local banName = banText:sub(1,banText:find(" ") or banText:len())
			banText = banText:sub((banText:find(" ") or banText:len())+1,banText:len())
			banCommand(client,banName,banText)
		end
	end
)


function banipCommand( thePlayer, theIP, reason )
	if not isPlayerOp( thePlayer ) then return end
	
	if theIP then
		-- strip spaces from the ip
		theIP = theIP:gsub(" ","")
	end
	
	if not theIP then
		return outputChatBox( "Usage: /banip <ip> [<reason>]", thePlayer, unpack( colour.personal ) )
	elseif not isValidIP( theIP ) then
		return outputChatBox( "Invalid ip.", thePlayer, unpack( colour.personal ) )
	end
	
	local text = "IP " .. theIP .. " was banned from the server by " .. getPlayerName( thePlayer )
--	local reason = table.concat( {...}, " " )
	if reason ~= "" then text = text .. " (" .. reason .. ")" end
	
	local result = addBan( theIP, nil, nil, thePlayer, reason ~= "" and reason or "none" )
	
	if result then 
		for _, value in ipairs( getElementsByType( "player" ) ) do
			if value and isElement( value ) and isPlayerOp( value ) then
				outputChatBox( text .. ".", value, unpack( colour.personal ) )
			end
		end
	else 
		outputChatBox( "Banning IP " .. theIP .. " failed.", thePlayer, unpack( colour.personal ) ) 
	end
end
addCommandHandler( "banip", function(player,command,ip,...)
	local reason = table.concat( {...}, " " )
	banipCommand(player,ip,reason)
end)


addEvent("serverBanIP",true)
addEventHandler("serverBanIP",root,
	function(banText)
		if banText and banText ~= "" then
			local ip = banText:sub(1,banText:find(" ") or banText:len())
			banText = banText:sub((banText:find(" ") or banText:len())+1,banText:len())
			banipCommand(client,ip,banText)
		end
	end
)


addEvent("serverBanSerial",true)
addEventHandler("serverBanSerial",root,
	function(banText)
		if banText and banText ~= "" then
			local serial = banText:sub(1,banText:find(" ") or banText:len())
			banText = banText:sub((banText:find(" ") or banText:len())+1,banText:len())
			
			serial = serial:gsub(" ","")
			
			local result = addBan(nil,nil,serial,client,banText,0)
			if result then
				for _, value in ipairs( getElementsByType( "player" ) ) do
					if value and isElement( value ) and isPlayerOp( value ) then
						outputChatBox( "Serial " .. serial .. " was banned from the server by " .. getPlayerName( client ), value, unpack( colour.personal ) )
					end
				end		
			else
				outputChatBox( "Banning serial " .. serial .. " failed.", client, unpack( colour.personal ) ) 
			end
		end
	end
)


addEvent("serverBanUsername",true)
addEventHandler("serverBanUsername",root,
	function(banText)
		if banText and banText ~= "" then
			local username = banText:sub(1,banText:find(" ") or banText:len())
			banText = banText:sub((banText:find(" ") or banText:len())+1,banText:len())
			
			username = username:gsub(" ","")
			
			local result = addBan(nil,username,nil,client,banText,0)
			if result then
				for _, value in ipairs( getElementsByType( "player" ) ) do
					if value and isElement( value ) and isPlayerOp( value ) then
						outputChatBox( "Username "..username.." was banned from the server by " .. getPlayerName(client), value, unpack( colour.personal ) )
					end
				end		
			else
				outputChatBox( "Banning username " .. username .. " failed.", client, unpack( colour.personal ) ) 
			end
		end
	end
)


function unbanipCommand( thePlayer, commandName, theIP )
	if not isPlayerOp( thePlayer ) then return end
	
	if not theIP then
		return outputChatBox( "Usage: /unbanip <ip>", thePlayer, unpack( colour.personal ) )
	elseif not isValidIP( theIP ) then
		return outputChatBox( "Invalid ip.", thePlayer, unpack( colour.personal ) )
	end
	
	local playerName = getPlayerName( thePlayer )
	local text = "IP " .. theIP .. " was unbanned from the server by " .. playerName .. "."

	
	local result = false
	for _,ban in ipairs(getBans()) do
		if getBanIP(ban) and getBanIP(ban) == theIP then
			-- cant just do result = removeBan incase one removeBan in the series fails and returns false when others have returned true
			local res = removeBan(ban, thePlayer)
			if res and not result then result = true end
		end
	end
	
	--local result = unbanIP( theIP, thePlayer )
	if result then 
		for _, value in ipairs( getElementsByType( "player" ) ) do
			if value and isElement( value ) and isPlayerOp( value ) then
				outputChatBox( text, value, unpack( colour.personal ) )
			end
		end
	else 
		outputChatBox( "Unbanning IP " .. theIP .. " failed.", thePlayer, unpack( colour.personal ) ) 
	end
end
addCommandHandler( "unbanip", unbanipCommand )


addEvent("serverUnbanIP",true)
addEventHandler("serverUnbanIP",root,
	function(ip)
		unbanipCommand(client,nil,ip)
	end
)


function unbanCommand( thePlayer, commandName, theString )
	if not isPlayerOp( thePlayer ) then return end
	
	if not theString then
		return outputChatBox( "Usage: /unban <name>", thePlayer, unpack( colour.personal ) )
	end
	
	local result
	for _,ban in ipairs(getBans()) do
		if ban and getBanNick(ban) and getBanNick(ban) == theString then
			local ip = getBanIP(ban)
			local res = removeBan(ban, thePlayer)
			if res then
				if not result then result = true end
				
				for _,p in ipairs( getElementsByType( "player" ) ) do
					if p and isElement( p ) and isPlayerOp( p ) then
						outputChatBox( theString .. " (" .. tostring( ip ) .. ") was unbanned from the server by " .. getPlayerName( thePlayer ) .. ".", p, unpack( colour.personal ) )
					end
				end
			end
		end
	end
	
	if not result then
		outputChatBox( "No bans found on " .. theString, thePlayer, unpack( colour.personal ) )
	end
end
addCommandHandler( "unban", unbanCommand )


addEvent("serverUnbanPlayer",true)
addEventHandler("serverUnbanPlayer",root,
	function(banPlayer)
		unbanCommand(client,nil,banPlayer)
	end
)


addEvent("serverUnbanSelected",true)
addEventHandler("serverUnbanSelected",root,
	function(index)
		local bans = getBans()
		if bans[index] then
			local banNick = getBanNick(bans[index])
			local ip = getBanIP(bans[index])
			
			removeBan(bans[index],client)
			
			for _, value in ipairs( getElementsByType( "player" ) ) do
				if value and isElement( value ) and isPlayerOp( value ) then
					outputChatBox( "Ban (" .. index .. ") ["..(banNick == false and "-" or tostring(banNick)).." - "..tostring(ip).."] was removed from the server by " .. getPlayerName(client) .. ".", value, unpack( colour.personal ) )
				end
			end
		end
	end
)



function checkipCommand( thePlayer, commandName, theIP )
	if not isPlayerOp( thePlayer ) then return end
	
	if not theIP then
		return outputChatBox( "Usage: /checkip <ip>", thePlayer, unpack( colour.personal ) )
	elseif not isValidIP( theIP, true ) then
		return outputChatBox( "Invalid ip.", thePlayer, unpack( colour.personal ) )
	end
	
	local numMatches, matches, text = isIPOnline( theIP )
	if numMatches == false then
		text = "There are no players online with ip " .. theIP
	else
		text = numMatches .. " player(s) with ip " .. theIP .. " : " .. matches
	end
	outputChatBox( text, thePlayer, unpack( colour.personal ) )
end
addCommandHandler( "checkip", checkipCommand )


function getipCommand( thePlayer, commandName, otherName )
	if not isPlayerOp( thePlayer ) then return end
	
	local otherPlayer = getPlayerFromNameSection( otherName )
	if otherPlayer == nil then
		return outputChatBox( "Usage: /getip <person>", thePlayer, unpack( colour.personal ) )
	elseif otherPlayer == false then
		return outputChatBox( "Too many matches for name '" .. otherName .. "'", thePlayer, unpack( colour.personal ) )
	end
	
	otherName = getPlayerName( otherPlayer )
	local ip = getPlayerIP( otherPlayer )
	outputChatBox( otherName .. ": " .. ip, thePlayer, unpack( colour.personal ) )
end
addCommandHandler( "getip", getipCommand )


function clearbansCommand( thePlayer )
	if not isPlayerOp( thePlayer ) then return end
	
	local count = 0
	for _,ban in ipairs(getBans()) do
		if ban then
			removeBan(ban, thePlayer)
			count = count + 1
		end
	end
	
	if count > 0 then
		outputChatBox( "Ban list (" .. count .. " ban(s)) cleared by " .. getPlayerName( thePlayer ), root, unpack( colour.global ) )
	end
end
addCommandHandler( "clearbans", clearbansCommand )


function searchBan( thePlayer, query )
	if not isPlayerOp( thePlayer ) then return nil end
	
	if not query then
		return "Usage: /searchban <string>"
	end
	
	local matches = {}
	for i,ban in ipairs(getBans()) do
		if ban then
			local match = false
			if getBanNick(ban) and getBanNick(ban) == query then
				matches[i] = ban
				match = true
			end
			
			if getBanIP(ban) and ipMatch(getBanIP(ban),query) and match == false then
				matches[i] = ban
				match = true
			end
			
			if getBanReason(ban) and match == false then
				if tostring(getBanReason(ban)):find(query) then 
					matches[i] = ban
					match = true
				end
			end		
			
			if getBanAdmin(ban) and getBanAdmin(ban) == query and match == false then
				matches[i] = ban
				match = true
			end		

			if getBanUsername(ban) and getBanUsername(ban) == query and match == false then
				matches[i] = ban
				match = true
			end		

			if getBanSerial(ban) and getBanSerial(ban) == query and match == false then
				matches[i] = ban
				match = true
			end	

			if getBanTime(ban) and match == false then
				local time = getRealTime(getBanTime(ban))
				local timeString = time.monthday.."/"..time.month.."/"..(time.year+1900).." - "..time.hour..":"..time.minute
				if timeString:find(query) then
					matches[i] = ban
					match = true
				end
			end							
		end	
	end
	
	return matches
end


addEvent("searchBans",true)
addEventHandler("searchBans",root,
	function(query)
		if query then
			local matches = searchBan(client,query)
			
			local index = {}
			for i,_ in pairs(matches) do
				table.insert(index,i)
			end
			
			triggerClientEvent(client, "returnBanSearch", root, index, tableSize(index))
		end
	end
)


addCommandHandler( "searchban", 
	function(player,command,query)
		local matches = searchBan(player,query)
		
		if matches then
			if tableSize(matches) > 0 then
				for _,match in pairs(matches) do
					local time = getRealTime(getBanTime(match))
					outputChatBox("Name: "..tostring(getBanNick(match))..
									" IP: "..tostring(getBanIP(match))..
									" Reason: "..tostring(getBanReason(match))..
									" Admin: "..tostring(getBanAdmin(match))..
									" Username: "..tostring(getBanUsername(match))..
									" Serial: "..tostring(getBanSerial(match))..
									" Time: "..(getBanTime(match) == false and "false" or time.monthday.."/"..time.month.."/"..(time.year+1900).." - "..time.hour..":"..time.minute), player, unpack( colour.personal ) )
				end
			else
				outputChatBox("No matches found for '"..query.."'.", player, unpack( colour.personal ) )
			end
		end
	end
)


function isValidIP( theIP, allowWildcards )
	allowWildcards = allowWildcards or false
	-- ASCII: 42 = *, 46 = ., 48 = 0, 50 = 2, 54 = 6, 57 = 9
	local count, charcount = 0, 0
	for i=1, #theIP, 1 do
		--if (theIP:byte( i ) < 48 or theIP:byte( i ) > 57) and theIP:byte( i ) ~= 46 and theIP:byte( i ) ~= 42 then
		--if (theIP:byte( i ) < 48 or theIP:byte( i ) > 57) and theIP:byte( i ) ~= 46 and theIP:byte( i ) == 42 then -- mta can't do range banning
		if allowWildcards then
			if (theIP:byte( i ) < 48 or theIP:byte( i ) > 57) and theIP:byte( i ) ~= 46 and theIP:byte( i ) ~= 42 then -- mta can't do range banning
				return false
			end
			if theIP:byte( i ) == 46 then
				count = count + 1
			end
			if theIP:byte( i ) ~= 46 then
				charcount = charcount + 1
			end
		else
			if (theIP:byte( i ) < 48 or theIP:byte( i ) > 57) and theIP:byte( i ) ~= 46 and theIP:byte( i ) == 42 then -- mta can't do range banning
				return false
			end
			if theIP:byte( i ) == 46 then
				count = count + 1
			end
			if theIP:byte( i ) ~= 46 then
				charcount = charcount + 1
			end
		end
	end
	if count ~= 3 then return false end
	if charcount < 4 then return false end
	if theIP:byte( 1 ) >= 50 and theIP:byte( 2 ) >= 54 and theIP:byte( 2 ) ~= 46 then return false end
	if theIP:byte( 1 ) == 42 then return false end
	return true
end


function isIPOnline( theIP )
	local ipcount = 0
	local matches = ""
	for key, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) then
			local pIP = getPlayerIP( value )
			if ipMatch( theIP, pIP ) then
				local playerName = getPlayerName( value )
				matches = matches .. playerName .. "(" .. pIP .. ") "
				ipcount = ipcount + 1
			end
		end
	end
	if ipcount == 0 then
		return false
	else
		return ipcount, matches
	end
end


function ipMatch( ip1, ip2) 
	local ip1_sections, ip2_sections = split(ip1,string.byte(".")), split(ip2,string.byte("."))
	
	for i=1, 4, 1 do
		if ip1_sections[i] and ip2_sections[i] then
			if ip1_sections[i] == ip2_sections[i] or ip1_sections[i] == "*" or ip2_sections[i] == "*" then
				-- the section matches
			else
				-- section doesnt match
				return false
			end
		else
			-- one or both dont have 4 sections, not valid ips, dont match
			return false
		end
	end
	
	return true
end


addEvent("getServerBans",true)
addEventHandler("getServerBans",root,function()
	local banTable = {}
	
	for i,ban in ipairs(getBans()) do
		banTable[i] = {}
		banTable[i].nick = getBanNick(ban)
		banTable[i].ip = getBanIP(ban)
		banTable[i].reason = getBanReason(ban)
		banTable[i].admin = getBanAdmin(ban)
		banTable[i].time = getBanTime(ban)
		banTable[i].username = getBanUsername(ban)
		banTable[i].serial = getBanSerial(ban)
	end
	
	triggerClientEvent(client, "returnServerBans", root, banTable)
end)


addEvent("canSeeBans",true)
addEventHandler("canSeeBans",root,
	function()
		triggerClientEvent(client, "clientSeeBans", client, isPlayerOp(client))
	end
)
