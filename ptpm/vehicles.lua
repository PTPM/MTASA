function isQualified( thePlayer, theVehicle, seat )
	if seat == 0 and getPlayerClassID( thePlayer ) then
		-- if the keys task has been activated
		if classes[getPlayerClassID( thePlayer )].type == "pm" and data.tasks.keys then 
			return true 
		end
		
		if not cantDrive[classes[getPlayerClassID( thePlayer )].type][getElementModel( theVehicle )] then 
			return true 
		end
		
		sendGameText( thePlayer, "You are not qualified\n to use this vehicle!", 2000, sampTextdrawColours.r, nil, 1.2, nil, nil, 1 )
		return false
	elseif seat ~= 0 then
		if not cantPassenger[classes[getPlayerClassID( thePlayer )].type][getElementModel( theVehicle )] then 
			return true
		end
		
		sendGameText( thePlayer, "You are not qualified\n to enter this vehicle!", 2000, sampTextdrawColours.r, nil, 1.2, nil, nil, 1 )
		return false
	end
end


addEventHandler( "onVehicleStartEnter", root,
	function( thePlayer, seat, jacked, door)
		local team = getPlayerTeam(thePlayer)
		
		if team then
			if jacked then
				if isPlayerInSameTeam( thePlayer, jacked ) then
					cancelEvent()
					sendGameText( thePlayer, "Please don't jack teammates!", 5000, sampTextdrawColours.r, nil, 1.2, nil, nil, 2 )
					return
				end
			end
		end	
	
		if not isQualified(thePlayer,source,seat) then
			cancelEvent()
		end
	end
)


addEventHandler( "onVehicleEnter", root,
	function( thePlayer )	
		-- if vehicleLaunch is enabled, its a rustler and its fresh then launch it
		if options and options.vehicleLaunch and getElementModel( source ) == 476 and data.vehicleRespawn[source].launched == false then
			launchVehicle( source )
		end
	end
)


function initiateVehicleRespawn()
	if isVehicleEmpty( source ) and data.vehicleRespawn and data.vehicleRespawn[source] and data.vehicleRespawn[source].delay then
		data.vehicleRespawn[source].timer = setTimer(
			function ( vehicle )
				doRespawnVehicle( vehicle )
				data.vehicleRespawn[vehicle].timer = nil
			end,
		data.vehicleRespawn[source].delay, 1, source )
		
		if options and options.vehicleLaunch and getElementModel(source) == 476 then
			data.vehicleRespawn[source].launched = true
		end
	end
end
addEventHandler( "onVehicleExit", root, initiateVehicleRespawn )


function stopVehicleRespawn( vehicle )
	if data.vehicleRespawn and data.vehicleRespawn[vehicle] and data.vehicleRespawn[vehicle].delay and data.vehicleRespawn[vehicle].timer then
		if isTimer( data.vehicleRespawn[vehicle].timer ) then
			killTimer( data.vehicleRespawn[vehicle].timer )
		end
		data.vehicleRespawn[vehicle].timer = nil
	end
end

function doStopVehicleRespawn()
	stopVehicleRespawn( source )
end
addEventHandler( "onVehicleEnter", root, doStopVehicleRespawn )
addEventHandler( "onVehicleExplode", root, doStopVehicleRespawn )


function doRespawnVehicle( vehicle )
	spawnVehicle( vehicle, getElementData( vehicle, "posX" ), getElementData( vehicle, "posY" ), getElementData( vehicle, "posZ" ), 0, 0, getElementData( vehicle, "rotZ" ) )
	
	if options and options.vehicleLaunch and getElementModel( vehicle ) == 476 then
		data.vehicleRespawn[vehicle].launched = false
	end
end


addEventHandler( "onVehicleRespawn", root,
	function()
		if options and options.vehicleLaunch and getElementModel( source ) == 476 then
			data.vehicleRespawn[source].launched = false
		end
	end
)


function isVehicleEmpty( vehicle )
	local maxPassengers = getVehicleMaxPassengers( vehicle )
	if maxPassengers then
		for i=0, maxPassengers do
			if getVehicleOccupant( vehicle, i ) then return false end
		end
	end
	return true
end


function launchVehicle(theVehicle)
	if theVehicle then
		local _,_,rz = getVehicleRotation(theVehicle)		
		rz = (360-rz)+90
		
		local px,py,pz = getElementPosition(theVehicle)
		

		vx = -1.2*math.cos(math.rad(rz))
		vy = 1.2*math.sin(math.rad(rz))
	  
		setElementPosition(theVehicle,px,py,pz+math.random(10,40))
		setElementVelocity(theVehicle,vx,vy,0)
		
		setVehicleLandingGearDown(theVehicle,false)
	end
end
