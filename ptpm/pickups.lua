﻿function onPickupHit( thePlayer )	cancelEvent()		local activeCamera = getElementData( thePlayer, "ptpm.activeCamera" )	local gettingOffCamera = getElementData( thePlayer, "ptpm.gettingOffCamera" )	if activeCamera or gettingOffCamera or isPedDead( thePlayer ) then return end	--if (playerInfo and playerInfo[thePlayer]) and (playerInfo[thePlayer].activeCamera or playerInfo[thePlayer].gettingOffCamera or isPedDead( thePlayer )) then return end			if getPickupType( source ) == 1 then -- armor		--if getPedOccupiedVehicle( thePlayer ) then return end	elseif getPickupType( source ) == 3 and getElementType(getElementParent( source )) == "cameraMount" then -- security camera		return prepareSecurityCamera( thePlayer, source )	elseif getPickupType( source ) == 3 and getElementData( source, "jetpack" ) == "true" and not doesPedHaveJetPack( thePlayer ) then -- jetpack		givePedJetPack( thePlayer )		bindKey( thePlayer, "enter_exit", "down", jetPackHandler )				if data.pickups[source].destroy then			destroyPickup( source )		end				return	elseif getPickupType( source ) == 3 then		return	end		if (getPickupWeapon( source ) == 38 or getPickupWeapon( source ) == 35 or getPickupWeapon( source ) == 36) and #getElementsByType( "player" ) <= 8 then		return sendGameText( thePlayer, "Heavy weapons disabled while there\nare 8 players or less", 6000, sampTextdrawColours.w, nil, 1.2, nil, nil, 2 )	end	local last = data.pickups[source].lastPickup[thePlayer] or false		if data.pickups[source].respawn then		if last and getPickupRespawnInterval( source ) - (getTickCount() - last) > 0 then			local text, name = "Respawns in " .. math.floor( (getPickupRespawnInterval( source ) - (getTickCount() - last)) / 1000 ) .. " seconds"			if data.pickups[source].synced then				if (not data.pickups[source].lastPickupBy) or (not getPlayerName( data.pickups[source].lastPickupBy )) then 					name = "(Logged out)"				else 					name = getPlayerName( data.pickups[source].lastPickupBy ) 				end				text = text .. "\nLast used by " .. name			end			sendGameText( thePlayer, text, 6000, sampTextdrawColours.y, nil, 1.2, nil, nil, 2 )		else			givePlayerPickupWeapon( thePlayer, source )		end	elseif not data.pickups[source].respawn then		if not last then -- never been picked up before			givePlayerPickupWeapon( thePlayer, source )		else			local text, name = "Weapon unavailable"			if data.pickups[source].synced then				if not data.pickups[source].lastPickupBy or not getPlayerName( data.pickups[source].lastPickupBy ) then name = "(Logged out)"				else name = getPlayerName( data.pickups[source].lastPickupBy ) end				text = text .. "\nAlready taken by " .. name			else				text = text .. "\n(Until you next die)"			end			sendGameText( thePlayer, text, 6000, sampTextdrawColours.y, nil, 1.2, nil, nil, 2 )		end	endendaddEventHandler( "onPickupHit", root, onPickupHit )function givePlayerPickupWeapon( thePlayer, thePickup )	if not getPlayerClassID( thePlayer ) then return end		local classID, weaponID = getPlayerClassID( thePlayer ), getPickupWeapon( thePickup )		if cantPickup[classes[classID].type] and cantPickup[classes[classID].type][weaponID] then		return sendGameText( thePlayer, "You are not qualified\nto use this weapon!", 6000, sampTextdrawColours.r, "pricedown", 1.2, "top", nil, 2 )	end		local pickupTime = getTickCount()		if data.pickups[thePickup].synced then		for _, value in ipairs( getElementsByType( "player" ) ) do			if value and isElement( value ) and isPlayerActive( value ) then				data.pickups[thePickup].lastPickup[value] = pickupTime			end		end		data.pickups[thePickup].lastPickupBy = thePlayer	else 		data.pickups[thePickup].lastPickup[thePlayer] = pickupTime	end		if getPickupType( thePickup ) == 1 then 		changeArmor( thePlayer, getPickupAmount( thePickup ) )	else 		giveWeapon( thePlayer, getPickupWeapon( thePickup ), getPickupAmmo( thePickup ), not getPedOccupiedVehicle( thePlayer ) and true or false )	end		playSoundFrontEnd( thePlayer, 19 )		if getPickupWeapon( thePickup ) == 38 or getPickupWeapon( thePickup ) == 35 or getPickupWeapon( thePickup ) == 36 then		local name, text = getPlayerName( thePlayer )		local teamName = teamMemberName[classes[classID].type]				if getPickupWeapon( thePickup ) == 38 then			text = name .. "(" .. teamName ..  ") has the minigun!"		elseif getPickupWeapon( thePickup ) == 35 then			text = name .. "(" .. teamName ..  ") has the rocket launcher!"		elseif getPickupWeapon( thePickup ) == 36 then			text = name .. "(" .. teamName ..  ") has the heat seeker!"		end				local r, g, b = getPlayerColour( thePlayer )		sendGameText( root, text, 3000, {r, g, b}, nil, 1.4, nil, nil, 2 )	end		if data.pickups[thePickup].destroy then		destroyPickup( thePickup )	endendfunction clearPickupData( thePlayer )	for _, value in ipairs( getElementsByType( "pickup", runningMapRoot ) ) do		if value and data.pickups[value] and data.pickups[value].lastPickupBy == thePlayer then			data.pickups[value].lastPickupBy = nil		end	endendfunction destroyPickup( pickup )	destroyElement( pickup )		if data.pickups[pickup].timer then		if isTimer( data.pickups[pickup].timer ) then			killTimer( data.pickups[pickup].timer )		end	end	data.pickups[pickup] = nil	end