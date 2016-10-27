local playerBlips = {}

addEvent( "onClientAvailable", true )

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
					
			if newValue then	
				local found
				
				for _,v in ipairs( newValue ) do
					if classID == v then
						found = true
					end
				end
					
				if not found then
					local r, g, b = getBlipColor( playerBlips[source] )
					setBlipColor( playerBlips[source], r, g, b, 0 )
				else
					local r, g, b = getBlipColor(playerBlips[source])
					setBlipColor( playerBlips[source], r, g, b, 255 )						
				end
			elseif newValue == false then
				if playerBlips[source] then
					local r, g, b = getBlipColor( playerBlips[source] )
					setBlipColor( playerBlips[source], r, g, b, 255 )	
				end
			end
		end
	end
)


addEventHandler( "onClientPlayerSpawn", localPlayer,
	function()
		local classID = getElementData( localPlayer, "ptpm.classID" )
		if classID then
			-- who should i be able to see now
			for _, p in ipairs( getElementsByType( "player" ) ) do
				if p and isElement( p ) then
					local visibleTo = getElementData( p, "ptpm.blip.visibleto" )
						
					if visibleTo then
						local found
						
						for _, c in ipairs( visibleTo ) do
							if classID == c then
								found = true
							end
						end
						
						if not found then
							local r, g, b = getBlipColor( playerBlips[p] )
							setBlipColor( playerBlips[p], r, g, b, 0 )
						else
							local r, g, b = getBlipColor( playerBlips[p] )
							setBlipColor( playerBlips[p], r, g, b, 255 )					
						end
					elseif visibleTo == false then
						if playerBlips[p] then
							local r, g, b = getBlipColor(playerBlips[p])
							setBlipColor( playerBlips[p], r, g, b, 255 )
						end
					end
				end
			end
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