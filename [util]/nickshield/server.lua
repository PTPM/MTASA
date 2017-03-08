-- Design:
--	Users can shield their nickname using /nickshield
-- 	The command will only work for logged in users
--	Nickshield only allows a PTPM_ACCOUNTS USER to shield ONE nickname
--	Nickshielded names will always need to be logged in
--	Nickshielded names are kicked after 45 seconds if they do not identify in time
--	Nickshielded names can not be used by any player that is already logged in as another user
--	Nickshielded names can not speak until they identify

ptpmColour = exports.ptpm:getColour("ptpm") or {255, 0, 0}
nickshielded = {
	["sampleNick"] = "sampleUserName"
}

function nickshieldedFlipped()
	local tt = {}
	for k,v in pairs(nickshielded) do
		tt[v] = k
	end
	
	return tt
end


-- File management
local files = { 
	nickshield = 			"nickshield.csv"
}

local filePointers = {}

for id,fileName in pairs(files) do
	if fileExists(fileName) then
		-- Set up append
		local fh = fileOpen ( fileName , true )
		filePointers[id] = fileGetSize(fh)
		fileClose(fh)
	else
		-- Create file
		local newFile = fileCreate(fileName)
		if not newFile then
			-- outputDebugString("FATAL: Can't create file " .. filename)
			-- die()
		end
		filePointers[id] = 0
	end
end

function openAndAppendToFile(fileID, theString)
	local fileName = files[fileID]
	local fileHandle = fileOpen(fileName)

	if not fileHandle then
		return
	end

	appendToFile(fileHandle, fileID, theString)

	fileClose(fileHandle)
end

function appendToFile(fileHandle, fileID, theString)
	fileSetPos(fileHandle, filePointers[fileID])
	fileWrite(fileHandle, theString .. "\n")
	filePointers[fileID] = fileGetPos(fileHandle)
end

function loadShieldedNicks()
	local buffer
	local hFile = fileOpen(files.nickshield, true)
	if hFile then   
		while not fileIsEOF(hFile) do   
			buffer = fileRead(hFile, 4096) 
		end
		fileClose(hFile)
	else
		-- outputDebugString("Unable to open " .. files.nickshield, 3)
	end
	
	local npLines = split(buffer,"\n")
	
	for _,line in ipairs(npLines) do
		local n = split(line, " ")
		nickshielded[n[1]] = n[2]
		
		
		-- outputDebugString("NEW SHIELD: " ..line)
		-- outputDebugString("NEW SHIELD: nick " .. n[1] .. " to user" .. n[2])
	end
end



function getPlayerPTPMUser(player)
	if not exports.ptpm:isRunning("ptpm_accounts") then return nil end
	
	local nick = exports.ptpm_accounts:getSensitiveUserdata( player, "username" )
	if not nick then		
		return "Guest"
	else
		return nick
	end
end




addCommandHandler ( "nickshield", function(source)
	local nick = getPlayerName(source)
	local user = getPlayerPTPMUser(source)
	
	if not user or user=="Guest" then 
		exports.ptpm:sendGameText(source, "Nickshield unavailable.", 3000, ptpmColour, nil, 1.5, nil, nil, 2)
		return
	end	
	
	-- Is this nick already shielded?
	if nickshielded[nick] then
		exports.ptpm:sendGameText(source, "This name is already shielded.", 3000, ptpmColour, nil, 1.5, nil, nil, 2)
		return
	end
	
	-- Does this user already have a shielded nick?
	if nickshieldedFlipped()[user] then
		exports.ptpm:sendGameText(source, "You're already shielding a name.", 3000, ptpmColour, nil, 1.5, nil, nil, 2)
		return
	end
	
	-- Protect the nick
	nickshielded[nick] = user
	openAndAppendToFile("nickshield", nick .. " " .. user)
	
	exports.ptpm:sendGameText(source, "This nick is now shielded.", 3000, ptpmColour, nil, 1.5, nil, nil, 2)

end )

function isThisAllowed(player, nick)
	-- return "yes", "maybe" or "no"
	--local nick = getPlayerName(player)
	local user = getPlayerPTPMUser(player)
	local verdict = ""
	
	local userOwner = nickshielded[nick]
	
	if userOwner then
		-- Is it a guest? Then it might be legit
		if user=="Guest" then 
			verdict = "maybe" 
		elseif userOwner~=user then 
			verdict = "no" 
		else 
			verdict = "yes" 
		end
	else
		verdict = "yes"
	end
	
	-- if not nickshielded or user==user then:
	-- outputDebugString("user " .. user .. " attempts use nick " .. nick .. ", allowed: " .. verdict,1)
	return verdict
end


addEventHandler ( "onPlayerJoin", getRootElement(), function()
	
	-- Wait five seconds, let it autologin if appropriate
	setTimer(function(thePlayer) 
		if isElement(thePlayer) then
			local verdict = isThisAllowed(thePlayer, getPlayerName(thePlayer))
			-- outputDebugString("onjoin : " .. verdict)

			if verdict=="no" then
				exports.namegen:namegen(thePlayer)
				-- outputDebugString("onjoin : ng")
			elseif verdict=="maybe" then
				exports.ptpm:sendGameText(thePlayer, "This name is shielded. You need to login within 30 seconds.", 3000, ptpmColour, nil, 1.5, nil, nil, 2)
				
				-- outputDebugString("onjoin : re eval")
				
				-- Re-evaluate in 30 seconds
				setTimer(function(thePlayer2)
					if isElement(thePlayer2) then
						local verdict = isThisAllowed(thePlayer2, getPlayerName(thePlayer2))
						if verdict~="yes" then
							kickPlayer (thePlayer2,"Failed to authenticate to shielded nickname.")
						end
					end
				end, 30000, 1, thePlayer)
			end
		end
	end, 5000, 1, source)
end )


addEventHandler("onPlayerChangeNick", getRootElement(), function(oldNick, newNick)
	local verdict = isThisAllowed(source, newNick)
	
	if verdict~="yes" then
		exports.ptpm:sendGameText(source, "This nickname is not available to you.", 3000, ptpmColour, nil, 1.5, nil, nil, 2)
        cancelEvent()
	end
end)



-- When the script restarts, reload shielded nicks
loadShieldedNicks()
