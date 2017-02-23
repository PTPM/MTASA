local playerBlips = {}

addEvent( "onClientAvailable", true )

addEventHandler( "onClientAvailable", localPlayer,
	function()
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) and p ~= localPlayer then
				local b = getElementData( p, "ptpm.blip" )
				if b and not playerBlips[p] then          
					playerBlips[p] = createBlipAttachedTo( p, 0, b[6], b[1], b[2], b[3], b[4], b[5] )
				end
			end
		end
	end
)

-- blip data: r, g, b, a, ordering, blipSize, interior
function blipsElementDataChange( element, dataName, oldValue )
	if dataName == "ptpm.blip" then
		local newValue = getElementData( element, "ptpm.blip" )

		-- we don't create a blip for ourselves
		if element ~= localPlayer then
			-- create blip
			if not oldValue and newValue then
				if not playerBlips[element] then
					playerBlips[element] = createBlipAttachedTo( element, 0, newValue[6], newValue[1], newValue[2], newValue[3], getBlipAlpha(newValue[4], newValue[7]), newValue[5] )
				end
			-- update data
			elseif oldValue and newValue then
				if playerBlips[element] then
					setBlipColor( playerBlips[element], newValue[1], newValue[2], newValue[3], getBlipAlpha(newValue[4], newValue[7]) )
					setBlipOrdering( playerBlips[element], newValue[5] )
          			setBlipSize( playerBlips[element], newValue[6] )
				end
			-- delete blip
			else
				if playerBlips[element] then
					destroyElement( playerBlips[element] )
					playerBlips[element] = nil
				end
			end
		end

		if element == currentPM then
			processPMInteriorDoorwayBlip(newValue and newValue[7] or 0)
		end
	elseif dataName == "ptpm.blip.visibleto" then
		local newValue = getElementData( element, "ptpm.blip.visibleto" )
		local classID = getElementData( localPlayer, "ptpm.classID" )
			
		applyBlipVisibleTo(classID, element, newValue)	
	end
end

function getBlipAlpha(proposedAlpha, theirInterior)
	if getElementInterior(localPlayer) == theirInterior then
		return proposedAlpha
	end

	return 0
end

function applyBlipVisibleTo(myClassID, player, visibleToValue)
	-- we don't create a blip for the local player
	if player == localPlayer then
		return
	end
	--outputDebugString("applyBlipVisibleTo " .. getPlayerName(player) .. " [" .. tostring(visibleToValue) .. "]")

	if visibleToValue then	
		local found
		
		for _,v in ipairs( visibleToValue ) do
			if myClassID == v then
				found = true
			end
		end

		if (not found) then
			local r, g, b = getBlipColor( playerBlips[player] )
			setBlipColor( playerBlips[player], r, g, b, 0 )
		else
			local r, g, b = getBlipColor(playerBlips[player])
			local blipData = getElementData(player, "ptpm.blip")
			setBlipColor( playerBlips[player], r, g, b, getBlipAlpha(255, blipData[7]) )						
		end
	else
		if playerBlips[player] then
			local r, g, b = getBlipColor( playerBlips[player] )
			local blipData = getElementData(player, "ptpm.blip")
			setBlipColor( playerBlips[player], r, g, b, getBlipAlpha(255, blipData[7]) )	
		end
	end
end

function processBlipVisibleTo() 
	local classID = getElementData(localPlayer, "ptpm.classID")

	if classID then		
		-- who should i be able to see now
		for _, p in ipairs(getElementsByType("player")) do
			if p and isElement(p) then
				local visibleTo = getElementData(p, "ptpm.blip.visibleto")
				
				applyBlipVisibleTo(classID, p, visibleTo)	
			end
		end
	end
end

function blipsClientPlayerSpawn()
	-- i just spawned, figure out who i should be able to see
	processBlipVisibleTo()

	if currentPM then
		local blipData = getElementData(currentPM, "ptpm.blip")
		processPMInteriorDoorwayBlip(blipData and blipData[7] or 0)
	end
end

addEvent("onClientInteriorWarped")
addEventHandler("onClientInteriorWarped", root,
	function()
		-- i teleported, figure out who i should be able to see
		processBlipVisibleTo()

		-- hide/show the pm doorway blip appropriately
		if currentPM then
			local blipData = getElementData(currentPM, "ptpm.blip")
			processPMInteriorDoorwayBlip(blipData and blipData[7] or 0)
		end
	end
)

-- called from onClientPlayerQuit
function removePlayerBlip(player)
	if playerBlips[player] then
		destroyElement( playerBlips[player] )
		playerBlips[player] = nil
	end
end


-- show/hide the pm interior doorway blip appropriately
function processPMInteriorDoorwayBlip(pmInterior) 
	if not currentPM then
		return
	end

	local blip = getElementByID("ptpm.blip.interior")

	if blip then
		local myInt = getElementInterior(localPlayer)
		local r, g, b, a = getBlipColor(blip)

		if pmInterior == myInt or myInt ~= 0 then
			setBlipColor(blip, r, g, b, 0)
		else
			setBlipColor(blip, r, g, b, 255)
		end
	end
end