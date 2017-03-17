function onPickupHit(thePlayer)
	cancelEvent()

	local activeCamera = getElementData(thePlayer, "ptpm.activeCamera")
	local gettingOffCamera = getElementData(thePlayer, "ptpm.gettingOffCamera")
	if activeCamera or gettingOffCamera or isPedDead(thePlayer) then 
		return
	end
	--if (playerInfo and playerInfo[thePlayer]) and (playerInfo[thePlayer].activeCamera or playerInfo[thePlayer].gettingOffCamera or isPedDead( thePlayer )) then return end
	
	if getPickupType(source) == 1 then -- armor
		--if getPedOccupiedVehicle( thePlayer ) then return end 
	elseif getPickupType(source) == 3 and getElementType(getElementParent(source)) == "cameraMount" then -- security camera
		return prepareSecurityCamera(thePlayer, source)
	elseif getPickupType(source) == 3 and getElementData(source, "jetpack") == "true" and not doesPedHaveJetPack(thePlayer) then -- jetpack
		givePedJetPack(thePlayer)
		bindKey(thePlayer, "enter_exit", "down", jetPackHandler)
		
		if data.pickups[source].destroy then
			destroyPickup(source)
		end		
		return
	elseif getPickupType(source) == 3 then
		return
	end
	
	if (getPickupWeapon(source) == 38 or getPickupWeapon(source) == 35 or getPickupWeapon(source) == 36) and #getElementsByType("player") <= 8 then
		return sendGameText(thePlayer, "Heavy weapons disabled while there\nare 8 players or less", 6000, colour.white, gameTextOrder.contextual)
	end

	local last = data.pickups[source].lastPickup[thePlayer] or false
	
	if data.pickups[source].respawn then
		if last and getPickupRespawnInterval(source) - (getTickCount() - last) > 0 then
			local text, name = "Respawns in " .. math.ceil((getPickupRespawnInterval(source) - (getTickCount() - last)) / 1000) .. " seconds"

			if data.pickups[source].synced then
				if (not data.pickups[source].lastPickupBy) or (not getPlayerName(data.pickups[source].lastPickupBy)) then 
					name = "(Logged out)"
				else 
					name = getPlayerName(data.pickups[source].lastPickupBy) 
				end

				text = text .. "\nLast used by " .. name
			end

			sendGameText(thePlayer, text, 6000, colour.sampYellow, gameTextOrder.contextual)
		else
			givePlayerPickupWeapon(thePlayer, source)
		end
	elseif not data.pickups[source].respawn then
		if data.pickups[source].lastPickupBy == nil then -- never been picked up before
			givePlayerPickupWeapon(thePlayer, source)
		else
			local text, name = "Weapon unavailable"
			if data.pickups[source].synced then
				if not data.pickups[source].lastPickupBy or not getPlayerName(data.pickups[source].lastPickupBy) then 
					name = "(Logged out)"
				else 
					name = getPlayerName( data.pickups[source].lastPickupBy) 
				end

				text = text .. "\nAlready taken by " .. name
			else
				text = text .. "\n(Until you next die)"
			end

			sendGameText(thePlayer, text, 6000, colour.sampYellow, gameTextOrder.contextual)
		end
	end
end
addEventHandler("onPickupHit", root, onPickupHit)


function givePlayerPickupWeapon(thePlayer, thePickup)
	if not getPlayerClassID(thePlayer) then return end
	
	local classID, weaponID = getPlayerClassID(thePlayer), getPickupWeapon(thePickup)
	
	if cantPickup[classes[classID].type] and cantPickup[classes[classID].type][weaponID] then
		return sendGameText(thePlayer, "You are not qualified\nto use this weapon!", 6000, colour.sampRed, gameTextOrder.contextual)
	end
	
	local pickupTime = getTickCount()
	
	if data.pickups[thePickup].synced then
		for _, value in ipairs(getElementsByType("player")) do
			if value and isElement(value) and isPlayerActive(value) then
				data.pickups[thePickup].lastPickup[value] = pickupTime
			end
		end
		data.pickups[thePickup].lastPickupBy = thePlayer
	else 
		data.pickups[thePickup].lastPickup[thePlayer] = pickupTime
	end

	if data.pickups[thePickup].respawn and (not data.pickups[thePickup].destroy) then
		if data.pickups[thePickup].synced then
			clearPickupRespawnTimer(thePickup)
			data.pickups[thePickup].respawnTimer = setTimer(pickupRespawn, getPickupRespawnInterval(source), 1, thePickup)
		else
			clearPickupPlayerRespawnTimer(thePickup, thePlayer)
			data.pickups[thePickup].playerRespawnTimer[thePlayer] = setTimer(pickupPlayerRespawn, getPickupRespawnInterval(source), 1, thePickup, thePlayer)
		end
	end

	if getPickupType(thePickup) == 1 then 
		changeArmor(thePlayer, getPickupAmount(thePickup))
	else 
		giveWeapon(thePlayer, weaponID, getPickupAmmo(thePickup), not getPedOccupiedVehicle(thePlayer) and true or false)
	end
	
	playSoundFrontEnd(thePlayer, 19)
	
	if weaponID == 38 or weaponID == 35 or weaponID == 36 then
		local name, text = getPlayerName(thePlayer)
		local teamName = ""

		if classes[classID].type == "pm" then
			teamName = "Prime Minister"
		elseif classes[classID].type == "police" then
			teamName = "Policeman"
		elseif classes[classID].type == "bodyguard" then
			teamName = "Bodyguard"
		elseif classes[classID].type == "terrorist" then
			teamName = "Terrorist"
		elseif classes[classID].type == "psycho" then
			teamName = "Psychopath"
		end
		
		if weaponID == 38 then
			text = teamName .. " " .. name .. " has the minigun!"
		elseif weaponID == 35 then
			text = teamName .. " " .. name .. " has the rocket launcher!"
		elseif weaponID == 36 then
			text = teamName .. " " .. name .. " has the heat seeker!"
		end
		
		if (isRunning("ptpm_announcer") and (weaponID==38 or weaponID==35 or weaponID==36)) then
			exports.ptpm_announcer:pickedUpSuperweapon(thePlayer, weaponID)
		end
		
		local r, g, b = getPlayerColour(thePlayer)
		sendGameText(root, text, 3000, {r, g, b}, gameTextOrder.global)
	elseif getPickupType(thePickup) == 2 then
		if data.pickups[thePickup].respawn then
			sendGameText(thePlayer, "Collected " .. getWeaponNameFromID(weaponID) .. "\nRespawns in " .. math.floor(getPickupRespawnInterval(thePickup) / 1000) .. " seconds", 6000, colour.sampGreen, gameTextOrder.normal)
		else
			sendGameText(thePlayer, "Collected " .. getWeaponNameFromID(weaponID), 6000, colour.sampGreen, gameTextOrder.normal)
		end
	end
	
	if data.pickups[thePickup].destroy then
		destroyPickup(thePickup)
	end
end

function pickupRespawn(thePickup)
	--outputChatBox("pickup respawned " ..tostring(getPickupType(thePickup)))

	-- this is to ensure that the pickup is able to picked up now, in case of minor timer disparity 
	-- (e.g. if the timer ticks at 990 instead of 1000 and there is still technically 10ms before it can be picked up)
	for _, player in ipairs(getElementsByType("player")) do
		if data.pickups[thePickup].lastPickup[player] then
			data.pickups[thePickup].lastPickup[player] = data.pickups[thePickup].lastPickup[player] - 500
		end
	end

	clearPickupRespawnTimer(thePickup)

	local px, py, pz = getElementPosition(thePickup)

	for _, player in ipairs(getElementsByType("player")) do
		if player and isPlayerActive(player) and getPlayerClassID(player) and (not isPedDead(player)) then
			local x, y, z = getElementPosition(player)

			if distanceSquared(px, py, pz, x, y, z) <= 1 then
				triggerEvent("onPickupHit", thePickup, player)

				-- if this player picked it up
				if data.pickups[thePickup].respawnTimer then
					return
				end
			end
		end
	end
end

function pickupPlayerRespawn(thePickup, player)
	--outputChatBox("pickup player respawned " ..tostring(getPickupType(thePickup)))

	if (not player) or (not isElement(player)) or (not thePickup) or (not isElement(thePickup)) then
		return
	end

	if data.pickups[thePickup].lastPickup[player] then
		data.pickups[thePickup].lastPickup[player] = data.pickups[thePickup].lastPickup[player] - 500
	end

	clearPickupPlayerRespawnTimer(thePickup, player)

	local px, py, pz = getElementPosition(thePickup)
	local x, y, z = getElementPosition(player)

	if (not isPedDead(player)) and distanceSquared(px, py, pz, x, y, z) <= 1 then
		triggerEvent("onPickupHit", thePickup, player)
	end
end


function clearPickupRespawnTimer(thePickup)
	if (not thePickup) or (not isElement(thePickup)) then
		return
	end
	
	if data.pickups[thePickup].respawnTimer then
		if isTimer(data.pickups[thePickup].respawnTimer) then
			killTimer(data.pickups[thePickup].respawnTimer)
		end
		data.pickups[thePickup].respawnTimer = nil
	end
end

function clearPickupPlayerRespawnTimer(thePickup, player)
	if (not player) or (not isElement(player)) or (not thePickup) or (not isElement(thePickup)) then
		return
	end

	if data.pickups[thePickup] and data.pickups[thePickup].playerRespawnTimer and data.pickups[thePickup].playerRespawnTimer[player] then
		if isTimer(data.pickups[thePickup].playerRespawnTimer[player]) then
			killTimer(data.pickups[thePickup].playerRespawnTimer[player])
		end
		data.pickups[thePickup].playerRespawnTimer[player] = nil
	end
end

function clearPickupData(thePlayer)
	if runningMapRoot and isElement(runningMapRoot) then
		for _, value in ipairs(getElementsByType("pickup", runningMapRoot)) do
			if value and data.pickups[value] and data.pickups[value].lastPickupBy == thePlayer then
				-- make a distinction between never picked up (nil) and picked up by an ex-player (false)
				data.pickups[value].lastPickupBy = false
			end

			clearPickupPlayerRespawnTimer(value, thePlayer)
		end
	end
end


function destroyPickup(pickup)
	clearPickupRespawnTimer(pickup)

	for _, player in ipairs(getElementsByType("player")) do
		clearPickupPlayerRespawnTimer(pickup, player)
	end

	destroyElement(pickup)
	
	if data.pickups[pickup].timer then
		if isTimer(data.pickups[pickup].timer) then
			killTimer(data.pickups[pickup].timer)
		end
	end
	data.pickups[pickup] = nil	
end
