addEvent( "onTeleportEnter", false )
addEventHandler( "onTeleportEnter", root,
	function( thePlayer )
		local tele = getElementParent( source )
		
		if data.teleports[tele].message ~= "" then 
			sendGameText( thePlayer, data.teleports[tele].message, 4000, colour.white, gameTextOrder.contextual ) 
		end 
		
		if getPedOccupiedVehicle( thePlayer ) and data.teleports[tele].vehicles then
			if not data.teleports[tele].exitDimX then
				setElementPosition( getPedOccupiedVehicle( thePlayer ), data.teleports[tele].teleX, data.teleports[tele].teleY, data.teleports[tele].teleZ )
			else
				local rangeX1, rangeX2 = data.teleports[tele].teleX + data.teleports[tele].exitDimX, data.teleports[tele].teleX - data.teleports[tele].exitDimX
				local rangeY1, rangeY2 = data.teleports[tele].teleY + data.teleports[tele].exitDimY, data.teleports[tele].teleY - data.teleports[tele].exitDimY
				setElementPosition( getPedOccupiedVehicle( thePlayer ), 	math.random( 0, rangeX1 - rangeX2 + 1 ) + rangeX2,
																			math.random( 0, rangeY1 - rangeY2 + 1 ) + rangeY2,
																			data.teleports[tele].teleZ )
			end
			setElementVelocity( getPedOccupiedVehicle( thePlayer ), 0, 0, 0 )
			setVehicleRotation( getPedOccupiedVehicle( thePlayer ), 0, 0, data.teleports[tele].teleRot )
		else
			if not data.teleports[tele].exitDimX then
				setElementPosition( thePlayer, data.teleports[tele].teleX, data.teleports[tele].teleY, data.teleports[tele].teleZ )
			else
				local rangeX1, rangeX2 = data.teleports[tele].teleX + data.teleports[tele].exitDimX, data.teleports[tele].teleX - data.teleports[tele].exitDimX
				local rangeY1, rangeY2 = data.teleports[tele].teleY + data.teleports[tele].exitDimY, data.teleports[tele].teleY - data.teleports[tele].exitDimY
				setElementPosition( thePlayer, 	math.random( 0, rangeX1 - rangeX2 + 1 ) + rangeX2,
												math.random( 0, rangeY1 - rangeY2 + 1 ) + rangeY2,
												data.teleports[tele].teleZ )
			end
			setElementVelocity( thePlayer, 0, 0, 0 )
			setPedRotation( thePlayer, data.teleports[tele].teleRot )
		end
	end
)
