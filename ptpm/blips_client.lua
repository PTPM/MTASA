local playerBlips = {}

addEvent( "onClientAvailable", true )
addEvent("onClientPlayerInteriorWarped", true)

--addEventHandler( "onClientResourceStart", resourceRoot,
addEventHandler( "onClientAvailable", localPlayer,
	function()
		for _, p in ipairs( getElementsByType( "player" ) ) do
			if p and isElement( p ) then
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
			-- create blip
			if not oldValue and newValue then
				if not playerBlips[source] then
					playerBlips[source] = createBlipAttachedTo( source, 0, newValue[6], newValue[1], newValue[2], newValue[3], newValue[4], newValue[5] )
					applyBlipVisibleTo(getElementData(localPlayer, "ptpm.classID"), source, getElementData(source, "ptpm.blip.visibleto"))
				end
			-- update data
			elseif oldValue and newValue then
				if playerBlips[source] then
					setBlipColor( playerBlips[source], newValue[1], newValue[2], newValue[3], newValue[4] )
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
		elseif dataName == "ptpm.blip.visibleto" then
			local newValue = getElementData( source, "ptpm.blip.visibleto" )
			local classID = getElementData( localPlayer, "ptpm.classID" )
				
			applyBlipVisibleTo(classID, source, newValue)	
		end
	end
)

function applyBlipVisibleTo(myClassID, player, visibleToValue)
	--outputDebugString("applyBlipVisibleTo " .. getPlayerName(player) .. " [" .. tostring(visibleToValue) .. "]")

	if visibleToValue then	
		local found
		
		for _,v in ipairs( visibleToValue ) do
			if myClassID == v then
				found = true
			end
		end

		local theirInterior = getElementInterior(player)
		local myInterior = getElementInterior(localPlayer)

		if (player == localPlayer) or (not found) or (myInterior ~= theirInterior) then
			local r, g, b = getBlipColor( playerBlips[player] )
			setBlipColor( playerBlips[player], r, g, b, 0 )
		else
			local r, g, b = getBlipColor(playerBlips[player])
			setBlipColor( playerBlips[player], r, g, b, 255 )						
		end
	-- elseif visibleToValue == false then
	-- 	if playerBlips[player] then
	-- 		local r, g, b = getBlipColor( playerBlips[player] )
	-- 		setBlipColor( playerBlips[player], r, g, b, 255 )	
	-- 	end
	else
		if not playerBlips[player] then
			return
		end

		-- for maps that don't have teamSpecificRadar set (i.e. everything except factory)
		local theirInterior = getElementInterior(player)
		local myInterior = getElementInterior(localPlayer)

		if (player == localPlayer) or (myInterior ~= theirInterior) then
			local r, g, b = getBlipColor( playerBlips[player] )
			setBlipColor( playerBlips[player], r, g, b, 0 )
		else
			local r, g, b = getBlipColor(playerBlips[player])
			setBlipColor( playerBlips[player], r, g, b, 255 )						
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


addEventHandler( "onClientPlayerSpawn", localPlayer,
	function()
		processBlipVisibleTo()
	end
)

addEventHandler("onClientPlayerInteriorWarped", resourceRoot,
	function(player)
		-- pm/me just teleported, so show/hide the doorway blip appropriately
		if player == currentPM or player == localPlayer then
			local blip = getElementByID("ptpm.blip.interior")

			if blip then
				local int = getElementInterior(currentPM)
				local myInt = getElementInterior(localPlayer)

				local r, g, b, a = getBlipColor(blip)

				if int == myInt then
					setBlipColor(blip, r, g, b, 0)
				else
					setBlipColor(blip, r, g, b, 255)
				end
			end
		end

		if player == localPlayer then
			-- i teleported, figure out who i should be able to see
			processBlipVisibleTo()
		else
			-- someone else teleported, figure out if i should be able to see them
			applyBlipVisibleTo(getElementData(player, "ptpm.classID"), player, getElementData(player, "ptpm.blip.visibleto"))
		end
	end
)


addEventHandler( "onClientPlayerQuit", root,
	function()
		if playerBlips[source] then
			destroyElement( playerBlips[source] )
			playerBlips[source] = nil
		end
	end
)