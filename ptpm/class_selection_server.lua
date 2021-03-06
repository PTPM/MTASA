﻿election = {
	active = false,
	candidates = {},
	
	addCandidate = 
		function(player, electors)
			if not election.active or getElementData(player, "ptpm.electionCandidate") or electors < 1 then
				return
			end

			if getElementData(player, "ptpm.electionClass") then
				setElementData(player, "ptpm.electionClass", nil, false)

				calculateBalance()
				notifyTeamAvailability()
			end

			setElementData(player, "ptpm.electionCandidate", true, false)
			triggerClientEvent(player, "updateClientChanceInElection", player, electors)
			
			for i=1,electors do
				table.insert(election.candidates, player)
			end

			for _, p in ipairs(getElementsByType("player")) do
				if p and isElement(p) and isPlayerActive(p) and getElementData(p, "ptpm.inClassSelection") then
					triggerClientEvent(p, "updateClassSelection", p, nil, #election.candidates)
				end
			end
		end,
		
	removeCandidate = 
		function(player)
			if not election.active or not getElementData(player, "ptpm.electionCandidate") then
				return
			end

			-- Iterating from back to front to remove the same value multiple times	
			for i=#election.candidates,1,-1 do
				if election.candidates[i] == player then
					table.remove(election.candidates, i)
				end
			end

			setElementData(player, "ptpm.electionCandidate", nil, false)	

			for _, p in ipairs(getElementsByType("player")) do
				if p and isElement(p) and isPlayerActive(p) and getElementData(p, "ptpm.inClassSelection") then
					triggerClientEvent(p, "updateClassSelection", p, nil, #election.candidates)
				end
			end		
		end,
}

appliedRecallEffects = {}
recallTimeNormal = 12000 --how long it takes for F4, /reclass, /swapclass to take effect, in milliseconds WHEN ENEMY IS NEAR
recallTimeBonus = 4000 --how long it takes for F4, /reclass, /swapclass to take effect, in milliseconds
			

addEvent("onPlayerRequestSpawn", true)
addEvent("sendPlayerToClassSelection", true)


-- call the client and initiate the class selection screen
function initClassSelection(thePlayer, updateBalanceAndNotify)
	if not data or data.roundEnded then 
		return 
	end
	
	if not isPlayerActive(thePlayer) or getElementData(thePlayer, "ptpm.inClassSelection") then 
		return 
	end

	setElementData(thePlayer, "ptpm.electionClass", nil, false)

	if getPlayerClassID(thePlayer) then
		setElementData(thePlayer, "ptpm.classID", false)
	end

	-- used e.g. when we go back to class selection after death
	if updateBalanceAndNotify then
		calculateBalance()
		notifyTeamAvailability()
	end

	setElementData(thePlayer, "ptpm.inClassSelection", true, false)
	
	setElementData(thePlayer, "ptpm.score.class", nil)
	setPlayerTeam(thePlayer, nil)
	resetPlayerColour(thePlayer)
	
	setPlayerControllable(thePlayer, false)

	local classSelectID = 1

	-- spawn the player just behind the camera
	local vec = Vector3(data.wardrobe.camX, data.wardrobe.camY, data.wardrobe.camZ) - Vector3(data.wardrobe.lookX, data.wardrobe.lookY, data.wardrobe.lookZ)
	vec:normalize()

	spawnPlayer(thePlayer, data.wardrobe.camX + vec:getX(), 
		data.wardrobe.camY + vec:getY(), 
		data.wardrobe.camZ + vec:getZ(), 
		0,
		classes[classSelectID].skin, 
		data.wardrobe.interior, 
		2000 + getPlayerId(thePlayer)
	)

	setElementFrozen(thePlayer, true)
	
	--setPlayerGravity( thePlayer, 0 )
	
	fadeCamera(thePlayer, true)
	
	setCameraMatrix(thePlayer, data.wardrobe.camX,
								data.wardrobe.camY,
								data.wardrobe.camZ,
								data.wardrobe.lookX,
								data.wardrobe.lookY,
								data.wardrobe.lookZ
					)
	setCameraInterior(thePlayer, data.wardrobe.interior)
	
	triggerClientEvent(thePlayer, "enterClassSelection", root, 
		runningMapName, 
		getRunningMapFriendlyNameWrapped(), 
		classes, 
		balance.full, 
		election.active, 
		#election.candidates, 
		getElementData(thePlayer, "ptpm.lastMapVote")
	)
	
	if data.currentMap.hasObjectives then
		clearObjectiveTextFor(thePlayer) 
	end
	
	if data.currentMap.hasTasks then
		clearTaskTextFor(thePlayer)
	end
end

addEventHandler("sendPlayerToClassSelection", resourceRoot,
	function()
		initClassSelection(client, true)
	end
)

function onPlayerRequestSpawn(requestedClassID)
	if not getElementData(client, "ptpm.inClassSelection") or getPlayerClassID(client) then
		return
	end

	-- electionClass only exists if they have reserved something in the class selection
	-- in which case, passing it allows for switching class within the same team while that team is full
	if not isBalanced(requestedClassID, getElementData(client, "ptpm.electionClass")) then 
	--if true then
		outputChatBox("Class not available.", client, unpack(colour.personal)) 
		triggerClientEvent(client, "onPlayerRequestSpawnDenied", root, requestedClassID)
		return
	end

	if election.active then
		-- pm is a special case because multiple people can request it
		if classes[requestedClassID].type == "pm" then
			if getElementData(client, "ptpm.electionCandidate") then
				election.removeCandidate(client)
				triggerClientEvent(client, "onPlayerRequestSpawnReserved", root, requestedClassID, true)
			else
				-- determine number of "ballot boxes" on the figurative ballot form, based on player experience
				-- if ptpm_accounts (statistics module) is not running, then elementData will be empty, and will work as expected with ballot forms = 1
				local electors = 1
				
				if isRunning("ptpm_accounts") then
					local gamesPlayed = (exports.ptpm_accounts:getPlayerStatistic( client, "roundswon" ) or 0) + (exports.ptpm_accounts:getPlayerStatistic( client, "roundslost" ) or 0)					
					if gamesPlayed >= 12 then electors = electors + 1 end	-- Get an additional box for 12 games played (based on PTPM Rank minimum)
					if gamesPlayed >= 40 then electors = electors + 1 end	-- Get an additional box for 40 games played (based on PTPM Rank League Cap)
					electors = electors + math.floor(gamesPlayed / 100)	-- Get an additional box for each 100 games played
				end
				
				election.addCandidate(client, electors)
				triggerClientEvent(client, "onPlayerRequestSpawnReserved", root, requestedClassID)
			end
		else
			-- tried to reserve something else while in the pm election, so remove from election
			if getElementData(client, "ptpm.electionCandidate") then
				election.removeCandidate(client)
				triggerClientEvent(client, "onPlayerRequestSpawnReserved", root, getPMClassID(), true)
			end

			-- if they select the same class again, remove their reservation
			if getElementData(client, "ptpm.electionClass") == requestedClassID then
				setElementData(client, "ptpm.electionClass", nil, false)

				triggerClientEvent(client, "onPlayerRequestSpawnReserved", root, requestedClassID, true)
			else
				-- save the class choice until the election is over
				setElementData(client, "ptpm.electionClass", requestedClassID, false)

				triggerClientEvent(client, "onPlayerRequestSpawnReserved", root, requestedClassID)
			end

			-- recalculate the balance with this new class reservation
			calculateBalance()
			notifyTeamAvailability()
		end
	else
		playerClassSelectionAccept(client, requestedClassID, true)
	end
end
addEventHandler("onPlayerRequestSpawn", root, onPlayerRequestSpawn)


-- spawn all the players that have reserved a class during the election
function spawnElection()
	local pmClassID = getPMClassID()

	if #election.candidates > 0 and pmClassID >= 0 then
		local randomCandidate = election.candidates[math.random(#election.candidates)]

		if randomCandidate and isElement(randomCandidate) then
			playerClassSelectionAccept(randomCandidate, pmClassID, true)
		else
			-- well, shit
			outputDebugString("Error: randomCandidate in election was invalid element")
		end

		election.candidates = {}
	end

	for _, player in ipairs(getElementsByType("player")) do
		if player and isElement(player) and isPlayerActive(player) then
			if getElementData(player, "ptpm.electionClass") then
				playerClassSelectionAccept(player, getElementData(player, "ptpm.electionClass"), false)

				setElementData(player, "ptpm.electionClass", nil, false)
			end

			if getElementData(player, "ptpm.electionCandidate") then
				if player ~= currentPM then
					triggerClientEvent(player, "onPlayerRequestSpawnReserved", root, pmClassID, true)
				end

				setElementData(player, "ptpm.electionCandidate", nil, false)
			end
		end
	end
end

function getPMClassID()
	for i, class in ipairs(classes) do
		if class.type == "pm" then
			return i
		end
	end
end


function playerClassSelectionAccept(thePlayer, classID, notify)
	classSelectionRemove(thePlayer)

	playSoundFrontEnd(thePlayer, 9)
	
	setPlayerClass(thePlayer, classID)

	if notify then
		notifyTeamAvailability()
	end

	bindKey(thePlayer, "f4", "down", "leaveclass")
end

function notifyTeamAvailability()
	--outputDebugString(string.format("FULL: pm: %s, bg: %s, cop: %s, terror: %s", tostring(balance.full.pm), tostring(balance.full.bodyguard), tostring(balance.full.police), tostring(balance.full.terrorist)))
	
	-- todo: only notify if the team-level state is actually different 
	for _, player in ipairs(getElementsByType("player")) do
		if isPlayerActive(player) and getElementData(player, "ptpm.inClassSelection") then
			triggerClientEvent(player, "updateClassSelection", player, balance.full)
		end
	end
end

function classSelectionRemove(thePlayer)
	if getElementData(thePlayer, "ptpm.inClassSelection") then
		setPlayerControllable(thePlayer, true)

		-- NOTE: Errors here for event not existing clientside when doing "gamemode ptpm"
		if runningMap then -- this fixes?
			triggerClientEvent(thePlayer, "leaveClassSelection", root)
		end

		setElementData(thePlayer, "ptpm.inClassSelection", false, false)
		setElementData(thePlayer, "ptpm.electionClass", nil, false)
	end
end

function leaveClassAfterTime(thePlayer)
	-- Pfff... bogus!
	if (not isPlayerActive(thePlayer)) or getElementData(thePlayer, "ptpm.inClassSelection") or isPedDead(thePlayer) then 
		return 
	end

	if appliedRecallEffects[thePlayer] ~= nil then 
		clearRecallEffect( thePlayer )
		outputChatBox("Leave class cancelled.", thePlayer, unpack(colour.personal))
		return
	end	

	local classID = getPlayerClassID(thePlayer)

	if not classID then
		return
	end

	if classes[classID].type == "pm" and not isPlayerOp(thePlayer) then
		outputChatBox("The prime minister must use /swapclass.", thePlayer, unpack(colour.personal))
		return
	end
	
	pX, pY, pZ = getElementPosition( thePlayer )
	local myTeam = getPlayerTeam( thePlayer ) 
	local lowestDistance = 9999999
	for _, player2 in ipairs( getElementsByType( "player" ) ) do
		if player2 and isElement( player2 ) and thePlayer ~= player2 and myTeam ~= getPlayerTeam(player2) then
			p2X, p2Y, p2Z = getElementPosition( player2 )
			local thisDistance = getDistanceBetweenPoints3D(pX, pY, pZ, p2X, p2Y, p2Z)
			if thisDistance < lowestDistance then
				lowestDistance = thisDistance
			end
		end
	end
	
	local thisRecallTime = recallTimeNormal
	-- Recall is faster with no enemies around and while outside
	if lowestDistance > 150 and getElementInterior(thePlayer) == 0 then
		thisRecallTime = recallTimeBonus
	end
	
	outputChatBox("Returning to class selection in " .. math.ceil(thisRecallTime / 1000) .. " seconds...", thePlayer, unpack(colour.personal))
	initRecallEffectToPlayer(thePlayer, thisRecallTime)
		
	if isRunning("ptpm_accounts") then
		exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "leaveclasscount")
	end
end
addCommandHandler("leaveclass", leaveClassAfterTime)

function initRecallEffectToPlayer( thePlayer, recallTime )
	colourR, colourG, colourB = getPlayerColour( thePlayer )
	
	pX, pY, pZ = getElementPosition( thePlayer )
	
	appliedRecallEffects[thePlayer] = {
		lightBeam = createMarker ( pX, pY, pZ, "checkpoint", 0, colourR, colourG, colourB, 0 ),
		timer = nil,
		progress = 0,
	}
	
	attachElements( appliedRecallEffects[thePlayer].lightBeam, thePlayer, 0, 0, 0, 0, 0, 0 )
	
	setPlayerControllable(thePlayer, false)
	setPedAnimation( thePlayer, "DANCING", "dnce_m_b")
	
	timerInterval = 50
	
	appliedRecallEffects[thePlayer].timer = setTimer(function()
		if appliedRecallEffects[thePlayer] == nil then return end
		
		pX, pY, pZ = getElementPosition( thePlayer )
		appliedRecallEffects[thePlayer].progress = appliedRecallEffects[thePlayer].progress + (timerInterval / recallTime)
		
		-- recall lightbeam starts slow and goes bigger faster (this element is attached to player so ElementPosition is not set)
		-- kinda looks like its recreated each time, causes flickering :thinking:
		setMarkerSize(appliedRecallEffects[thePlayer].lightBeam, 2 - (getEasingValue( appliedRecallEffects[thePlayer].progress, "InOutQuad" ) * 2))
		setElementAlpha( thePlayer, 255 - (127 * getEasingValue( appliedRecallEffects[thePlayer].progress, "InOutQuad" )))
				
		if appliedRecallEffects[thePlayer].progress >= 0.999 then
			if thePlayer and isElement(thePlayer) and not data.roundEnded then
				if isPedInVehicle(thePlayer) then
					removePedFromVehicle(thePlayer)
				end

				initClassSelection(thePlayer, true)
				unbindKey(thePlayer, "f4", "down", "leaveclass")
			end
			clearRecallEffect( thePlayer )
		end
	
	end, timerInterval, recallTime / timerInterval)	
end

function clearRecallEffect( thePlayer )
	if appliedRecallEffects[thePlayer] == nil then return end

	setPedAnimation(thePlayer, false)
	setPlayerControllable(thePlayer, true)
	killTimer(appliedRecallEffects[thePlayer].timer)
	setElementAlpha( thePlayer, 255)
	destroyElement(appliedRecallEffects[thePlayer].lightBeam)
	appliedRecallEffects[thePlayer] = nil
end

-- Recall is cancelled upon taking damage, dying and quitting
addEventHandler ( "onPlayerDamage", getRootElement(), function() clearRecallEffect(source) end )
addEventHandler ( "onPlayerWasted", getRootElement(), function() clearRecallEffect(source) end )
addEventHandler ( "onPlayerQuit", getRootElement(), function() clearRecallEffect(source) end )


function reclassCommand( thePlayer, commandName, className )
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	-- /reclass has been discontinued in favor of SpawnSelect2 
	-- (because /rc was an artifact out of the cmd-based game design from the SAMP days)
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------

	if data.roundEnded then return end
	
	--if not antiSpam( thePlayer ) then return end

	local classID = getPlayerClassID( thePlayer )
	if not classID then return end
	
	if isPedDead( thePlayer ) then return end

	if classes[classID].type == "pm" and not isPlayerOp( thePlayer ) then
		return outputChatBox( "The prime minister must use /swapclass.", thePlayer, unpack( colour.personal ) )
	end

	if not isPlayerControllable( thePlayer ) or isPlayerFrozen( thePlayer ) then
	--if playerInfo[thePlayer].frozen then
		return outputChatBox( "You cannot reclass while frozen.", thePlayer, unpack( colour.personal ) )
	end
	
	if getElementData( thePlayer, "ptpm.watching" ) then
		return outputChatBox( "You cannot reclass while watching.", thePlayer, unpack( colour.personal ) )
	end
	
	local proposedClass = false

	if not className or #className == 0 then
		return outputChatBox( "Usage: /reclass pm|terrorist|cop|bodyguard|psycho|tmedic|bmedic|cmedic", thePlayer, unpack( colour.personal ) )
	elseif tonumber( className ) ~= nil then
		proposedClass = tonumber( className )
		if proposedClass > #classes or proposedClass <= 0 then
			outputChatBox( "No such class.", thePlayer, unpack( colour.personal ) )
			outputChatBox( "Usage: /reclass pm|terrorist|cop|bodyguard|psycho|tmedic|bmedic|cmedic", thePlayer, unpack( colour.personal ) )
			return
		end
		--if proposedClass > #classes then return end
	else
		local search, medic = nil,nil
		
		if className == "cop" or className == "c" then
			search = "police"
		elseif className == "terrorist" or className == "t" or className == "terror" then
			search = "terrorist"
		elseif className == "bodyguard" or className == "b" or className == "bg" then
			search = "bodyguard"
		elseif className == "psycho" or className == "p" or className == "psychopath" then
			search = "psycho"
		elseif className == "pm" or className == "prime" or className == "primeminister" then
			search = "pm"
		elseif className == "tmedic" or className == "tm" then
			search = "terrorist"
			medic = true
		elseif className == "bmedic" or className == "bm" then
			search = "bodyguard"
			medic = true
		elseif className == "cmedic" or className == "cm" then
			search = "police"
			medic = true
		end
		
		if search then
			local potentials = {}
			for i = 1, #classes, 1 do
				if classes[i] and classes[i].type == search and (not medic or classes[i].medic) then
					potentials[#potentials+1] = i
				end
			end		
			
			if #potentials > 0 then
				proposedClass = potentials[math.random(1, #potentials)]
			end
		else
			outputChatBox( "No such class.", thePlayer, unpack( colour.personal ) )
			outputChatBox( "Usage: /reclass pm|terrorist|cop|bodyguard|psycho|tmedic|bmedic|cmedic", thePlayer, unpack( colour.personal ) )
			return
		end
	end

	if proposedClass == false then 
		return outputChatBox( "Class not available.", thePlayer, unpack( colour.personal ) ) 
	end

	if isBalanced(proposedClass, classID) then
		setPlayerClass( thePlayer, proposedClass )

		if commandName == "reclass" then
			triggerHelpEvent(thePlayer, "COMMAND_RC")
			if isRunning("ptpm_accounts") then
				exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "reclasscount")
			end
		elseif commandName == "rc" then
			if isRunning("ptpm_accounts") then
				exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "rccount")
			end
		end
	else
		local teamName = teamMemberName[classes[proposedClass].type]
		outputChatBox( "Could not spawn as " .. teamName .. ", that class is full.", thePlayer, unpack( colour.personal ) )	
	end
end

addCommandHandler( "reclass", leaveClassAfterTime )
addCommandHandler( "rc", leaveClassAfterTime )


function swapclass( thePlayer, commandName, otherName )
	if data.roundEnded then return end
	
	if not getPlayerClassID( thePlayer ) or classes[getPlayerClassID( thePlayer )].type ~= "pm" then
		return outputChatBox( "You must be the Prime Minister to use this.", thePlayer, unpack( colour.personal ) )
	end
	
	if otherName then
		local otherPlayer = getPlayerFromNameSection( otherName )
		if otherPlayer == nil then
			return outputChatBox( "Usage: /swapclass <person>", thePlayer, unpack( colour.personal ) )
		elseif otherPlayer == false then
			return outputChatBox( "Too many matches for name '" .. otherName .. "'", thePlayer, unpack( colour.personal ) )
		elseif not getPlayerClassID( otherPlayer ) then
			return outputChatBox( "That person has not yet selected a class.", thePlayer, unpack( colour.personal ) )
		elseif otherPlayer == thePlayer then
			return outputChatBox( "You are the Prime Minister.", thePlayer, unpack( colour.personal ) )
		elseif options.swapclass.target then
			return outputChatBox( "You may not swapclass with two people at once.", thePlayer, unpack( colour.personal ) )
		end  

		triggerHelpEvent(otherPlayer, "COMMAND_SWAPCLASS_TARGET")

		options.swapclass.target = otherPlayer
		options.swapclass.timer = setTimer( swapclassOffer, 15000, 1, false, otherPlayer )

		outputChatBox( "Swapclass offer sent to " .. getPlayerName( otherPlayer ), thePlayer, unpack( colour.personal ) )

		if isRunning("ptpm_accounts") then
			exports.ptpm_accounts:incrementPlayerStatistic(thePlayer, "swapclasscount")
		end
	end
end


function swapclassOffer(accepted, thePlayer)
	if options.swapclass.target ~= thePlayer then 
		return 
	end
	
	if options.swapclass.timer then
		if isTimer(options.swapclass.timer) then
			killTimer(options.swapclass.timer)
		end
	end

	hideHelpEvent(thePlayer, "COMMAND_SWAPCLASS_TARGET")

	if accepted then
		local victimClass = getPlayerClassID(thePlayer)
		local pmClass = getPlayerClassID(currentPM)
			
		setPlayerClass(currentPM, victimClass)
		setPlayerClass(thePlayer, pmClass)	

		notifyTeamAvailability()
	else
		if currentPM then 
			outputChatBox("Your offer to " .. getPlayerName(thePlayer) .. " was declined.", currentPM, unpack(colour.personal)) 
		end
	end
	options.swapclass = {}
end


function swapclassAccept( thePlayer )
	if data.roundEnded then return end
	
	if currentPM and options.swapclass.target == thePlayer then
		swapclassOffer( true, thePlayer )
	end
end


function swapclassDecline( thePlayer )
	if data.roundEnded then return end
	
	if currentPM and options.swapclass.target == thePlayer then
		swapclassOffer( false, thePlayer )
	end
end
addCommandHandler( "swapclass", swapclass )
addCommandHandler( "y", swapclassAccept )
addCommandHandler( "n", swapclassDecline )