-- Design:
--	Users can shield their nickname using /nickshield
-- 	The command will only work for logged in users
--	Nickshield only allows a PTPM_ACCOUNTS USER to shield ONE nickname
--	Nickshielded names will always need to be logged in
--	Nickshielded names are kicked after 25 seconds if they do not identify in time
--	Nickshielded names can not be used by any player that is already logged in as another user
--	Nickname usage from registration serial is allowed

ptpmColour = exports.ptpm:getColour("ptpm") or {255, 0, 0}
nickshielded = {
	["sampleNick"] = {
		["user"] = "sampleUserName",
		["serial"] = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	}
}

function isUserAssociatedWithAnyNickname(user)
	for k,v in pairs(nickshielded) do
		if v["user"]==user then return true end
	end
	
	return false
end


-- File management
local files = { 
	nickshield = 			"nickshield.csv",
	incidents = 			"incidents.log"
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
		nickshielded[n[1]] = {
			["user"] = n[2],
			["serial"] = n[3] or "UNKNOWNSERIAL"
		}
		
		
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


function now()
	local t = getRealTime( )
	return t.timestamp
end


function registerNickshield(player)
	local nick = getPlayerName(player):lower()
	local user = getPlayerPTPMUser(player)
	
	if not user then 
		exports.ptpm:sendGameText(player, "Nickshield unavailable right now.", 3000, ptpmColour, 3, 1.3)
		return
	end	
	
	if user=="Guest" then 
		exports.ptpm:sendGameText(player, "Nickshield unavailable to guests.", 3000, ptpmColour, 3, 1.3)
		return
	end	
	
	-- Is this nick already shielded?
	if nickshielded[nick] then
		exports.ptpm:sendGameText(player, "This nickname is already shielded.", 3000, ptpmColour, 3, 1.3)
		return
	end
	
	-- Does this user already have a shielded nick?
	if isUserAssociatedWithAnyNickname(user) then
		exports.ptpm:sendGameText(player, "You're already shielding a nickname.", 3000, ptpmColour, 3, 1.3)
		return
	end
	
	-- Protect the nick
	registerNickshieldRaw(nick, user, getPlayerSerial(player))
	exports.ptpm:sendGameText(player, "This nickname is now shielded.", 3000, ptpmColour, 3, 1.3)
end

function registerNickshieldRaw(nick, user, serial)
	nickshielded[nick] = user
	openAndAppendToFile("nickshield", nick .. " " .. user .. " " .. serial)
end


addCommandHandler ( "nickshield", registerNickshield )

function isThisAllowed(player, nick)
	nick = nick:lower()
	
	-- return "yes", "maybe" or "no"
	--local nick = getPlayerName(player)
	local user = getPlayerPTPMUser(player)
	local verdict = ""
	
	local owner = nickshielded[nick]
	
	if owner then
		-- Nickname belongs to somebody...
		if user=="Guest" and getPlayerSerial(player)==owner["serial"] then 
			-- Hasn't logged in, but serial checks out, so allow it.
			verdict = "yes" 
		elseif user=="Guest" then 
			-- Hasn't logged in yet, might be OK. Kick if player doesn't identify in time.
			verdict = "maybe" 
		elseif owner["user"]~=user then 
			-- It's a different user, just don't allow it
			verdict = "no" 
		else 
			-- The only remaining cases are to allow it.
			verdict = "yes" 
		end
	else
		-- Nickname belongs to nobody: always allowed.
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
				openAndAppendToFile("incidents", now() .. "¶" .. getPlayerName(thePlayer2) .. "¶" .. getPlayerSerial(thePlayer2) .. "¶NG-autosignin")
				exports.namegen:namegen(thePlayer)
				-- outputDebugString("onjoin : ng")
			elseif verdict=="maybe" then
				exports.ptpm:sendGameText(thePlayer, "This name is shielded. You need to login within 30 seconds.", 3000, ptpmColour, 3, 1.3)
				
				-- outputDebugString("onjoin : re eval")
				
				-- Re-evaluate in 30 seconds
				setTimer(function(thePlayer2)
					if isElement(thePlayer2) then
						local verdict = isThisAllowed(thePlayer2, getPlayerName(thePlayer2))
						if verdict~="yes" then
							openAndAppendToFile("incidents", now() .. "¶" .. getPlayerName(thePlayer2) .. "¶" .. getPlayerSerial(thePlayer2) .. "¶NG-eval")
							--kickPlayer (thePlayer2,"This nickname is protected. You must sign in as '" .. nickshielded[getPlayerName(thePlayer2)]["user"] .. "' in order to use. Otherwise, use a different nickname.")
							
							exports.ptpm:sendGameText(player, "Log in as '" .. nickshielded[getPlayerName(thePlayer2)]["user"]   .. "' to use nickname '" .. getPlayerName(thePlayer2) .. "'.", 3000, ptpmColour, 3, 1.3)
							exports.namegen:namegen(thePlayer2)
						end
					end
				end, 20000, 1, thePlayer)
			end
		end
	end, 5000, 1, source)
end )


addEventHandler("onPlayerChangeNick", getRootElement(), function(oldNick, newNick)
	local verdict = isThisAllowed(source, newNick)
	
	if verdict~="yes" then
		openAndAppendToFile("incidents", now() .. "¶" .. newNick .. "¶" .. getPlayerSerial(source) .. "¶CHANGE PREVENTED")
		exports.ptpm:sendGameText(source, "This nickname is not available to you.", 3000, ptpmColour, 3, 1.3)
        cancelEvent()
	end
end)



-- When the script restarts, reload shielded nicks
loadShieldedNicks()
