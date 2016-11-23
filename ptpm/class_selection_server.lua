addEvent("onPlayerRequestSpawn", true)


-- compcheck
-- call the client and initiate the class selection screen
function initClassSelection(thePlayer)
	if not data or data.roundEnded then 
		return 
	end
	
	if not isPlayerActive(thePlayer) or getElementData(thePlayer, "ptpm.inClassSelection") then 
		return 
	end

	setElementData(thePlayer, "ptpm.inClassSelection", true, false)

	if getPlayerClassID(thePlayer) then
		setElementData(thePlayer, "ptpm.classID", false)
	end
	
	setElementData(thePlayer, "ptpm.score.class", nil)
	setPlayerTeam(thePlayer, nil)
	resetPlayerColour(thePlayer)
	
	setPlayerControllable(thePlayer, false)

	--local class = getElementData( thePlayer, "class" )
	local classSelectID = tonumber(getElementData(thePlayer, "ptpm.classSelect.id")) or 1

	spawnPlayer(thePlayer, data.wardrobe.playerX,
							data.wardrobe.playerY,
							data.wardrobe.playerZ,
							data.wardrobe.playerRot,
							classes[classSelectID].skin,
							data.wardrobe.interior,
							2000 + getPlayerId(thePlayer)
				)
	
	--setPlayerGravity( thePlayer, 0 )
	
	fadeCamera(thePlayer, true)
	
	setCameraMatrix(thePlayer, data.wardrobe.camX,
								data.wardrobe.camY,
								data.wardrobe.camZ,
								data.wardrobe.playerX,
								data.wardrobe.playerY,
								data.wardrobe.playerZ
					)
	setCameraInterior(thePlayer, data.wardrobe.interior)
	
	-- bindKey( thePlayer, "arrow_l", "down", scrollClassSelection, -1 )
	-- bindKey( thePlayer, "arrow_r", "down", scrollClassSelection, 1 )
	-- bindKey( thePlayer, "arrow_l", "up", scrollClassSelectionInterrupt, -1)
	-- bindKey( thePlayer, "arrow_r", "up", scrollClassSelectionInterrupt, 1)
	-- bindKey( thePlayer, "lshift", "down", playerClassSelectionAccept )
	-- bindKey( thePlayer, "rshift", "down", playerClassSelectionAccept )
	-- bindKey( thePlayer, "enter", "down", playerClassSelectionAccept )
	-- bindKey( thePlayer, "lctrl", "both", leftControlToggle )
	-- bindKey( thePlayer, "rctrl", "both", rightControlToggle )
	
	--showPlayerHudComponent( thePlayer, "radar", false )
	
	--local weapons = getElementData( classes[classSelectID].class, "weapons" )

	triggerClientEvent(thePlayer, "enterClassSelection", root, runningMapName, classes, balance.full)

	-- triggerClientEvent( thePlayer, "updateClassSelectionScreen", root, "create", 
	-- 					classSelectID, 
	-- 					classes[classSelectID].type, 
	-- 					classes[classSelectID].medic, 
	-- 					vetoPlayerClass( classSelectID, false ) ~= classSelectID,
	-- 					weapons,
	-- 					tableSize( getElementsByType( "objective", runningMapRoot ) ) > 0
	-- 				  )

	--triggerClientEvent( thePlayer, "updateClassSelectionScreen", root, "create", 
	--					playerInfo[thePlayer].class.id, 
	--					classes[playerInfo[thePlayer].class.id].type, 
	--					classes[playerInfo[thePlayer].class.id].medic, 
	--					vetoPlayerClass( playerInfo[thePlayer].class.id, false ) ~= playerInfo[thePlayer].class.id, 
	--					getElementData( classes[playerInfo[thePlayer].class.id].class, "weapons" ),  
	--					tableSize(getElementsByType( "objective", runningMapRoot )) > 0
	--				  )
	
	
	if tableSize(getElementsByType("objective", runningMapRoot)) > 0 then
		clearObjectiveTextFor(thePlayer) 
	end
	
	if tableSize(getElementsByType("task", runningMapRoot)) > 0 then
		clearTaskTextFor(thePlayer)
	end
end

function onPlayerRequestSpawn(requestedClassID)
	if not getElementData(client, "ptpm.inClassSelection") then
		return
	end

	if not isBalanced(requestedClassID, false) then 
	--if true then
		triggerClientEvent(client, "onPlayerRequestSpawnDenied", root, requestedClassID)
		return
	end

	playerClassSelectionAccept(client, requestedClassID)
end
addEventHandler("onPlayerRequestSpawn", root, onPlayerRequestSpawn)


addCommandHandler("jt", 
	function(player, cmd, team)
		calculateBalance()
		balance.full[team] = true
		debugFunc("post", balance.full)
		notifyTeamAvailability()
	end
)
addCommandHandler("lt", 
	function(player, cmd, team)
		calculateBalance()
		balance.full[team] = false
		notifyTeamAvailability()
	end
)


-- compcheck
-- function leftControlToggle( thePlayer, _, keystate )
-- 	if keystate == "down" then
-- 		setElementData( thePlayer, "ptpm.classSelect.lctrl", true, false )
-- 		--playerInfo[thePlayer].class.lctrl = true
-- 	else
-- 		setElementData( thePlayer, "ptpm.classSelect.lctrl", false, false )
-- 		--playerInfo[thePlayer].class.lctrl = false
-- 	end
-- end

-- compcheck
-- function rightControlToggle( thePlayer, _, keystate )
-- 	if keystate == "down" then
-- 		setElementData( thePlayer, "ptpm.classSelect.rctrl", true, false )
-- 		--playerInfo[thePlayer].class.rctrl = true
-- 	else
-- 		setElementData( thePlayer, "ptpm.classSelect.rctrl", false, false )
-- 		--playerInfo[thePlayer].class.rctrl = false
-- 	end
-- end

-- compcheck
-- triggered by a left/right arrow keypress, changes the currently selected class in the class selection screen
-- function scrollClassSelection( thePlayer, _, _, leftOrRight )

-- 	local lctrl = getElementData( thePlayer, "ptpm.classSelect.lctrl" )
-- 	local rctrl = getElementData( thePlayer, "ptpm.classSelect.rctrl" )
-- 	local ctrl = lctrl or rctrl
-- 	--local ctrl = playerInfo[thePlayer].class.lctrl or playerInfo[thePlayer].class.rctrl
-- 	local oldClassID = getElementData( thePlayer, "ptpm.classSelect.id" )
-- 	local nextClassID = oldClassID
-- 	--local oldclassid = playerInfo[thePlayer].class.id
	
-- 	repeat -- NOTE: FAILS!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 		nextClassID = nextClassID + leftOrRight
-- 		--playerInfo[thePlayer].class.id = playerInfo[thePlayer].class.id + leftOrRight
		
-- 		-- wrap around
-- 		if nextClassID < 0 then nextClassID = #classes
-- 		elseif nextClassID > #classes then nextClassID = 0 end
-- 		--if playerInfo[thePlayer].class.id < 0 then playerInfo[thePlayer].class.id = #classes
-- 		--elseif playerInfo[thePlayer].class.id > #classes then playerInfo[thePlayer].class.id = 0 end
-- 	until 	classes[nextClassID] and (not ctrl or (classes[nextClassID].type ~= classes[oldClassID].type) or (nextClassID == oldClassID))
-- 	--until classes[playerInfo[thePlayer].class.id] and
-- 	--	((ctrl and ((classes[playerInfo[thePlayer].class.id].type ~= classes[oldclassid].type) or (playerInfo[thePlayer].class.id == oldclassid))) or
-- 	--	(ctrl == nil))
-- 	setElementData( thePlayer, "ptpm.classSelect.id", nextClassID, false )
	
-- 	local skin = getElementData( classes[nextClassID].class, "skin" )
-- 	spawnPlayer( thePlayer, data.wardrobe.playerX,
-- 							data.wardrobe.playerY,
-- 							data.wardrobe.playerZ,
-- 							data.wardrobe.playerRot,
-- 							skin,
-- 							data.wardrobe.interior,
-- 							2000 + getPlayerId( thePlayer ) )
	
-- 	--setPlayerGravity( thePlayer, 0 )
	
-- 	if leftOrRight == 1 then
-- 		playSoundFrontEnd( thePlayer, 6 ) 
		
-- 		local autoLeft = getElementData( thePlayer, "ptpm.classSelect.autoLeft" )
-- 		if autoLeft then
-- 			killTimer( autoLeft )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoLeft", nil, false )
-- 		end
-- 		--if playerInfo[thePlayer].class.autoLeft then
-- 		--	killTimer(playerInfo[thePlayer].class.autoLeft)
-- 		--	playerInfo[thePlayer].class.autoLeft = nil
-- 		--end
		
-- 		local autoRight = getElementData( thePlayer, "ptpm.classSelect.autoRight" )
-- 		if not autoRight then
-- 			autoRight = setTimer( scrollClassSelection, 300, 0, thePlayer, nil, nil, leftOrRight )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoRight", autoRight, false )
-- 		end
-- 		--if not playerInfo[thePlayer].class.autoRight then
-- 		--	playerInfo[thePlayer].class.autoRight = setTimer(scrollClassSelection,500,0,thePlayer,nil,nil,leftOrRight)
-- 		--end
-- 	elseif leftOrRight == -1 then 
-- 		playSoundFrontEnd( thePlayer, 14 ) 
		
-- 		local autoRight = getElementData( thePlayer, "ptpm.classSelect.autoRight" )
-- 		if autoRight then
-- 			killTimer( autoRight )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoRight", nil, false )
-- 		end
-- 		--if playerInfo[thePlayer].class.autoRight then
-- 		--	killTimer(playerInfo[thePlayer].class.autoRight)
-- 		--	playerInfo[thePlayer].class.autoRight = nil
-- 		--end		
		
-- 		local autoLeft = getElementData( thePlayer, "ptpm.classSelect.autoLeft" )
-- 		if not autoLeft then
-- 			autoLeft = setTimer( scrollClassSelection, 300, 0, thePlayer, nil, nil, leftOrRight )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoLeft", autoLeft, false )
-- 		end
-- 		--if not playerInfo[thePlayer].class.autoLeft then
-- 		--	playerInfo[thePlayer].class.autoLeft = setTimer(scrollClassSelection,500,0,thePlayer,nil,nil,leftOrRight)
-- 		--end
-- 	end

-- 	local isClassFull = (vetoPlayerClass( nextClassID, false ) ~= nextClassID)
-- 	--local isClassFull = (vetoPlayerClass( playerInfo[thePlayer].class.id, false ) ~= playerInfo[thePlayer].class.id)
	
-- 	if isClassFull then
-- 		unbindKey( thePlayer, "lshift", "down", playerClassSelectionAccept )
-- 		unbindKey( thePlayer, "rshift", "down", playerClassSelectionAccept )
-- 		unbindKey( thePlayer, "enter", "down", playerClassSelectionAccept )
-- 	else
-- 		bindKey( thePlayer, "lshift", "down", playerClassSelectionAccept )
-- 		bindKey( thePlayer, "rshift", "down", playerClassSelectionAccept )
-- 		bindKey( thePlayer, "enter", "down", playerClassSelectionAccept )
-- 	end

-- 	local weapons = getElementData( classes[nextClassID].class, "weapons" )
-- 	triggerClientEvent( thePlayer, "updateClassSelectionScreen", root, "sync", 
-- 						nextClassID, 
-- 						classes[nextClassID].type, 
-- 						classes[nextClassID].medic, 
-- 						isClassFull, 
-- 						weapons, 
-- 						tableSize( getElementsByType( "objective", runningMapRoot ) ) > 0
-- 					  )
-- 	--triggerClientEvent( thePlayer, "updateClassSelectionScreen", root, "sync", 
-- 	--					playerInfo[thePlayer].class.id, 
-- 	--					classes[playerInfo[thePlayer].class.id].type, 
-- 	--					classes[playerInfo[thePlayer].class.id].medic, 
-- 	--					isClassFull, 
-- 	--					getElementData( classes[playerInfo[thePlayer].class.id].class, "weapons" ), 
-- 	--					tableSize(getElementsByType( "objective", runningMapRoot )) > 0
-- 	--				  )
-- end

-- compcheck
-- function scrollClassSelectionInterrupt( thePlayer, _, _, leftOrRight )
-- 	if leftOrRight == 1 then
-- 		local autoRight = getElementData( thePlayer, "ptpm.classSelect.autoRight" )
-- 		if autoRight then
-- 			killTimer( autoRight )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoRight", nil, false )
-- 		end
-- 		--if playerInfo[thePlayer].class and playerInfo[thePlayer].class.autoRight then
-- 		--	killTimer(playerInfo[thePlayer].class.autoRight)
-- 		--	playerInfo[thePlayer].class.autoRight = nil
-- 		--end
-- 	elseif leftOrRight == -1 then
-- 		local autoLeft = getElementData( thePlayer, "ptpm.classSelect.autoLeft" )
-- 		if autoLeft then
-- 			killTimer( autoLeft )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoLeft", nil, false )
-- 		end
-- 		--if playerInfo[thePlayer].class and playerInfo[thePlayer].class.autoLeft then
-- 		--	killTimer(playerInfo[thePlayer].class.autoLeft)
-- 		--	playerInfo[thePlayer].class.autoLeft = nil
-- 		--end
-- 	end
-- end

-- compcheck
function playerClassSelectionAccept(thePlayer, classID)
	classSelectionRemove(thePlayer)

	playSoundFrontEnd(thePlayer, 9)
	
	-- the logic behind this is to avoid using the actual onPlayerSpawn event, which would be triggering every time the class selection is scrolled
	-- actually, i dont think there is any logic
	--doOnPlayerSpawn( thePlayer )
	
	-- override class if unavailable
	--local classSelectionID = getElementData(thePlayer, "ptpm.classSelect.id")
	--local veto = vetoPlayerClass(classSelectionID, getPlayerClassID(thePlayer))
	--local veto = vetoPlayerClass( playerInfo[thePlayer].class.id, getPlayerClassID( thePlayer ) )
	--if classSelectionID ~= veto then 
	--if playerInfo[thePlayer].class.id ~= veto then 
	--	outputChatBox("The class you selected was full, picking something else...", thePlayer, unpack(colourImportant)) 
	--end
	
	setPlayerClass(thePlayer, classID)

	notifyTeamAvailability()

	bindKey(thePlayer, "f4", "down", classSelectionAfterDeath)
end

function notifyTeamAvailability()
	-- local pmFull = not isBalanced("pm")
	-- local bodyguardFull = not isBalanced("bodyguard")
	-- local policeFull = not isBalanced("police")
	-- local terroristFull = not isBalanced("terrorist")

	for _, player in ipairs(getElementsByType("player")) do
		if isPlayerActive(player) and getElementData(player, "ptpm.inClassSelection") then
			triggerClientEvent(player, "updateClassSelection", player, balance.full)
		end
	end
end

-- compcheck
function classSelectionRemove(thePlayer)
	if getElementData(thePlayer, "ptpm.inClassSelection") then
		setPlayerControllable(thePlayer, true)
		
		-- unbindKey( thePlayer, "arrow_l", "down", scrollClassSelection )
		-- unbindKey( thePlayer, "arrow_r", "down", scrollClassSelection )
		-- unbindKey( thePlayer, "lshift", "down", playerClassSelectionAccept )
		-- unbindKey( thePlayer, "rshift", "down", playerClassSelectionAccept )
		-- unbindKey( thePlayer, "enter", "down", playerClassSelectionAccept )
		-- unbindKey( thePlayer, "lctrl", "both", leftControlToggle )
		-- unbindKey( thePlayer, "rctrl", "both", rightControlToggle )
		
		-- NOTE: Errors here for event not existing clientside when doing "gamemode ptpm"
		if runningMap then -- this fixes?
			triggerClientEvent(thePlayer, "leaveClassSelection", root)
		end
		
		--showPlayerHudComponent( thePlayer, "radar", true )
		
		setElementData(thePlayer, "ptpm.inClassSelection", false, false)
	end
end

-- compcheck
-- function checkClassSelection( thePlayer )
-- 	--if playerInfo and playerInfo[thePlayer] then
-- 		local autoRight = getElementData( thePlayer, "ptpm.classSelect.autoRight" )
-- 		if autoRight then
-- 			killTimer( autoRight )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoRight", nil, false )
-- 		end
-- 		--if playerInfo[thePlayer].class.autoRight then
-- 		--	killTimer(playerInfo[thePlayer].class.autoRight)
-- 		--	playerInfo[thePlayer].class.autoRight = nil
-- 		--end

-- 		local autoLeft = getElementData( thePlayer, "ptpm.classSelect.autoLeft" )
-- 		if autoLeft then
-- 			killTimer( autoLeft )
-- 			setElementData( thePlayer, "ptpm.classSelect.autoLeft", nil, false )
-- 		end
-- 		--if playerInfo[thePlayer].class.autoLeft then
-- 		--	killTimer(playerInfo[thePlayer].class.autoLeft)
-- 		--	playerInfo[thePlayer].class.autoLeft = nil
-- 		--end			
-- 	--end
-- end

-- compcheck
function classSelectionAfterDeath( thePlayer )
	unbindKey( thePlayer, "f4", "down", classSelectionAfterDeath )
	setElementData( thePlayer, "ptpm.classSelectAfterDeath", true, false )
	--playerInfo[thePlayer].classAfterDeath = true
	outputChatBox( "Returning to class selection after next death.", thePlayer, unpack( colourPersonal ) )
end

-- compcheck
function reclassCommand( thePlayer, commandName, className )
	if data.roundEnded then return end
	
	--if not antiSpam( thePlayer ) then return end

	local classID = getPlayerClassID( thePlayer )
	if not classID then return end
	
	if isPedDead( thePlayer ) then return end

	if classes[classID].type == "pm" and not isPlayerOp( thePlayer ) then
		return outputChatBox( "The prime minister must use /swapclass.", thePlayer, unpack( colourPersonal ) )
	end

	if not isPlayerControllable( thePlayer ) or isPlayerFrozen( thePlayer ) then
	--if playerInfo[thePlayer].frozen then
		return outputChatBox( "You cannot reclass while frozen.", thePlayer, unpack( colourPersonal ) )
	end
	
	local watching = getElementData( thePlayer, "ptpm.watching" )
	if watching then
	--if playerInfo[thePlayer].watching then
		return outputChatBox( "You cannot reclass while watching.", thePlayer, unpack( colourPersonal ) )
	end
	
	local proposedClass = false

	if not className or #className == 0 then
		return outputChatBox( "Usage: /reclass pm|terrorist|cop|bodyguard|psycho|tmedic|bmedic|cmedic", thePlayer, unpack( colourPersonal ) )
	elseif tonumber( className ) ~= nil then
		proposedClass = tonumber( className )
		if proposedClass > #classes or proposedClass < 0 then
			outputChatBox( "No such class.", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "Usage: /reclass pm|terrorist|cop|bodyguard|psycho|tmedic|bmedic|cmedic", thePlayer, unpack( colourPersonal ) )
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
			outputChatBox( "No such class.", thePlayer, unpack( colourPersonal ) )
			outputChatBox( "Usage: /reclass pm|terrorist|cop|bodyguard|psycho|tmedic|bmedic|cmedic", thePlayer, unpack( colourPersonal ) )
			return
		end
	end

	if proposedClass == false then 
		return outputChatBox( "Class not available.", thePlayer, unpack( colourPersonal ) ) 
	end

	if isBalanced(proposedClass, classID) then
		setPlayerClass( thePlayer, proposedClass )
	else
		local teamName = teamMemberName[classes[proposedClass].type]
		outputChatBox( "Could not spawn as " .. teamName .. ", that class is full.", thePlayer, unpack( colourPersonal ) )	
	end
end
addCommandHandler( "reclass", reclassCommand )
addCommandHandler( "rc", reclassCommand )


function swapclass( thePlayer, commandName, otherName )
	if data.roundEnded then return end
	
	if not getPlayerClassID( thePlayer ) or classes[getPlayerClassID( thePlayer )].type ~= "pm" then
		return outputChatBox( "You must be the Prime Minister to use this.", thePlayer, unpack( colourPersonal ) )
	end
	
  if(otherName) then
    local otherPlayer = getPlayerFromNameSection( otherName )
    if otherPlayer == nil then
      return outputChatBox( "Usage: /swapclass <person>", thePlayer, unpack( colourPersonal ) )
    elseif otherPlayer == false then
      return outputChatBox( "Too many matches for name '" .. otherName .. "'", thePlayer, unpack( colourPersonal ) )
    elseif not getPlayerClassID( otherPlayer ) then
      return outputChatBox( "That person has not yet selected a class.", thePlayer, unpack( colourPersonal ) )
    elseif otherPlayer == thePlayer then
      return outputChatBox( "You are the Prime Minister.", thePlayer, unpack( colourPersonal ) )
    elseif options.swapclass.target then
      return outputChatBox( "You may not swapclass with two people at once.", thePlayer, unpack( colourPersonal ) )
    end  
	
    drawStaticTextToScreen( "draw", otherPlayer, "swapText", "The Prime Minister wants to swapclass with you.\nType /y to accept or /n to decline.", "screenX-340", "screenY-60", 320, 40, colourImportant, 1, "clear" )

    options.swapclass.target = otherPlayer
    options.swapclass.timer = setTimer( swapclassOffer, 15000, 1, false, otherPlayer )
    
    outputChatBox( "Swapclass offer sent to " .. getPlayerName( otherPlayer ), thePlayer, unpack( colourPersonal ) )
  end
end


function swapclassOffer( accepted, thePlayer )
	if options.swapclass.target ~= thePlayer then return end
	
	if options.swapclass.timer then
		if isTimer( options.swapclass.timer ) then
			killTimer( options.swapclass.timer )
		end
	end

	if accepted then
		local victimClass = getPlayerClassID( thePlayer )
		local pmClass = getPlayerClassID( currentPM )
			
		setPlayerClass( currentPM, victimClass )
		setPlayerClass( thePlayer, pmClass )	
			
		drawStaticTextToScreen( "delete", thePlayer, "swapText" )
	else
		drawStaticTextToScreen( "delete", thePlayer, "swapText" )
		
		if currentPM then 
			outputChatBox( "Your offer to " .. getPlayerName( thePlayer ) .. " was declined.", currentPM, unpack( colourPersonal ) ) 
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