addEvent("onVehicleIdleRespawn")
addEvent("onPlayerWastedInVehicle", true)

function isQualified( thePlayer, theVehicle, seat )
	if seat == 0 and getPlayerClassID( thePlayer ) then
		-- if the keys task has been activated
		if classes[getPlayerClassID( thePlayer )].type == "pm" and data.tasks.keys then 
			return true 
		end
		
		if not cantDrive[classes[getPlayerClassID( thePlayer )].type][getElementModel( theVehicle )] then 
			return true 
		end
		
		sendGameText( thePlayer, "You are not qualified\n to use this vehicle!", 2000, colour.sampRed, gameTextOrder.contextual )
		return false
	elseif seat ~= 0 then
		if not cantPassenger[classes[getPlayerClassID( thePlayer )].type][getElementModel( theVehicle )] then 
			return true
		end
		
		sendGameText( thePlayer, "You are not qualified\n to enter this vehicle!", 2000, colour.sampRed, gameTextOrder.contextual )
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
					sendGameText( thePlayer, "Please don't jack teammates!", 5000, colour.sampRed, gameTextOrder.normal )
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
	function(thePlayer)	
		doStopVehicleRespawn()

		-- if vehicleLaunch is enabled, its a rustler and its fresh then launch it
		if options and options.vehicleLaunch and getElementModel(source) == 476 and getElementData(source, "ptpm.vehicle.fresh") and not getElementData(source, "noLaunch") then
			launchVehicle(source)
		end

		setVehicleStale(source)

		if data.currentMap.hasAmbulances and getElementModel(source) == 416 then
			local class = getPlayerClassID(thePlayer)

			if classes[class].medic then
				-- triggerHelpEvent(thePlayer, "MEDIC_AMBULANCE")
			end
		end

		if currentPM and thePlayer == currentPM and (not options.disablePMHealthbar) then
			if isRunning("world_draw") then
				exports.world_draw:attach3DDraw(source, "pmhb", "healthbar")
			end
		end
	end
)


-- can't get this info serverside (isPedInVehicle/etc returns false inside onPlayerWasted), so get it from the client instead and trigger the proper events
addEventHandler("onPlayerWastedInVehicle", root,
	function(vehicle, seat)
		triggerEvent("onVehicleExit", vehicle, client, seat)
		triggerEvent("onPlayerVehicleExit", client, vehicle, seat)
	end
)


function initiateVehicleRespawn(vehicle)
	if isVehicleEmpty(vehicle) and data.vehicleRespawn and data.vehicleRespawn[vehicle] and data.vehicleRespawn[vehicle].delay then
		data.vehicleRespawn[vehicle].timer = setTimer(
			function (v)
				doRespawnVehicle(v)
				data.vehicleRespawn[v].timer = nil
				triggerEvent("onVehicleIdleRespawn", v)
			end,
		data.vehicleRespawn[vehicle].delay, 1, vehicle)

		-- just in case
		setVehicleStale(vehicle)
	end
end
addEventHandler("onVehicleExit", root, 
	function(player, seat, jacked)
		initiateVehicleRespawn(source)

		if currentPM and player == currentPM and (not options.disablePMHealthbar) then
			if isRunning("world_draw") then
				exports.world_draw:detach3DDraw(source, "pmhb")
			end
		end
	end
)


function setVehicleStale(vehicle)
	setElementData(vehicle, "ptpm.vehicle.fresh", nil, false)

	setVehicleDamageProof(vehicle, false)
end


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
addEventHandler( "onVehicleExplode", root, doStopVehicleRespawn )


function doRespawnVehicle( vehicle )
	spawnVehicle( vehicle, getElementData( vehicle, "posX" ), getElementData( vehicle, "posY" ), getElementData( vehicle, "posZ" ), 0, 0, getElementData( vehicle, "rotZ" ) )

	onVehicleRespawn(vehicle)
end

function onVehicleRespawn(vehicle)
	setElementData(vehicle, "ptpm.vehicle.fresh", true, false)
end

addEventHandler("onVehicleRespawn", root, 
	function()
		onVehicleRespawn(source)
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
