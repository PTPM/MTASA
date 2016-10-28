local playerBlips = {}

addEvent( "onClientAvailable", true )

--addEventHandler( "onClientResourceStart", resourceRoot,
addEventHandler( "onClientAvailable", localPlayer,
	function()
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) and p ~= localPlayer then
				local b = getElementData( p, "ptpm.blip" )
				if b then          
					playerBlips[p] = createBlipAttachedTo( p, 0, b[6], b[1], b[2], b[3], b[4], b[5] )
				end
			end
		end
	end
)


addEventHandler( "onClientElementDataChange", root,
	function( dataName, oldValue )
		if dataName == "ptpm.blip" then
			local newValue = getElementData( source, "ptpm.blip" )

			-- we don't create a blip for ourselves
			if source ~= localPlayer then
				-- create blip
				if not oldValue and newValue then
					if not playerBlips[source] then
						playerBlips[source] = createBlipAttachedTo( source, 0, newValue[6], newValue[1], newValue[2], newValue[3], getBlipAlpha(newValue[4], newValue[7]), newValue[5] )
					end
				-- update data
				elseif oldValue and newValue then
					if playerBlips[source] then
						setBlipColor( playerBlips[source], newValue[1], newValue[2], newValue[3], getBlipAlpha(newValue[4], newValue[7]) )
						setBlipOrdering( playerBlips[source], newValue[5] )
	          			setBlipSize( playerBlips[source], newValue[6] )
					end
				-- delete blip
				else
					if playerBlips[source] then
						destroyElement( playerBlips[source] )
						playerBlips[source] = nil
					end
				end
			end

			if source == currentPM then
				processPMInteriorDoorwayBlip(newValue and newValue[7] or 0)
			end
		elseif dataName == "ptpm.blip.visibleto" then
			local newValue = getElementData( source, "ptpm.blip.visibleto" )
			local classID = getElementData( localPlayer, "ptpm.classID" )
				
			applyBlipVisibleTo(classID, source, newValue)	
		end
	end
)

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
	local classID = getElementData( localPlayer, "ptpm.classID" )

	if classID then		
		-- who should i be able to see now
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) then
				local visibleTo = getElementData( p, "ptpm.blip.visibleto" )
				
				applyBlipVisibleTo(classID, p, visibleTo)	
			end
		end
	end
end

addEventHandler("onClientPlayerSpawn", localPlayer,
	function()
		-- i just spawned, figure out who i should be able to see
		processBlipVisibleTo()

		if currentPM then
			local blipData = getElementData(currentPM, "ptpm.blip")
			processPMInteriorDoorwayBlip(blipData and blipData[7] or 0)
		end
	end
)

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

addEventHandler("onClientPlayerQuit", root,
	function()
		if playerBlips[source] then
			destroyElement( playerBlips[source] )
			playerBlips[source] = nil
		end
	end
)


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