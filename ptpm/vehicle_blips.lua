--[[
local vBlips = {}
function vehicleBlipHandler( key, keyState )
	if keyState == "down" then
		local pX, pY, pZ = getElementPosition( localPlayer )
		local vehicles = getElementsByType( "vehicle" )
		for key, value in ipairs(vehicles) do
			if value then
				local x, y, z = getElementPosition( value )
				if getDistanceBetweenPoints3D( pX, pY, pZ, x, y, z ) <= 250 then
					vBlips[value] = createBlip( x, y, z, 0, 1, 200, 200, 200, 150, 0 )
					attachElements( vBlips[value], value )
				end
			end
		end
	elseif keyState == "up" then
		local vehicles = getElementsByType( "vehicle" )
		for key, value in ipairs(vehicles) do
			if value and vBlips[value] then
				detachElements( vBlips[value], value )
				destroyElement( vBlips[value] )
				vBlips[value] = nil
			end
		end
	end
end
bindKey( "F2", "both", vehicleBlipHandler )
]]

vehicleBlips = {}
vehicleBlips.active = true
vehicleBlips.enabled = true


addEventHandler( "onClientElementStreamIn", root,
	function()
		if vehicleBlips.enabled and vehicleBlips.active then
			if getElementType( source ) == "vehicle" then
				createVehicleBlip( source )
			end
		end
	end
)


addEventHandler( "onClientElementStreamOut", root,
	function()
		if getElementType( source ) == "vehicle" then
			destroyVehicleBlip( source )
		end
	end
)


--[[addEventHandler( "onClientElementDestroy", root,
	function()
		if getElementType( source ) == "vehicle" then -- source = bad argument
			destroyVehicleBlip( source )
		end
	end
)--]]


addEvent( "onClientMapStop", true )
addEventHandler( "onClientMapStop", root, 
	function()
		for v, _ in pairs( vehicleBlips ) do
			if tostring( v ) ~= "active" and tostring( v ) ~= "enabled" then
				destroyVehicleBlip( v )
			end
		end
		vehicleBlips.enabled = false
	end
)


addEvent( "onClientMapStart", true )
addEventHandler( "onClientMapStart", root,
	function()
		vehicleBlips.enabled = true
	end
)


bindKey( "F2", "down",
	function()
		vehicleBlips.active = not vehicleBlips.active
		
		-- generate blips for all streamed in vehicles
		if vehicleBlips.active then
			for _, vehicle in ipairs( getElementsByType( "vehicle" ) ) do
				if isElementStreamedIn( vehicle ) then
					createVehicleBlip( vehicle )
				end
			end
		-- remove all current blips
		elseif not vehicleBlips.active then
			for v, _ in pairs( vehicleBlips ) do
				if tostring( v ) ~= "active" and tostring( v ) ~= "enabled" then
					destroyVehicleBlip( v )
				end
			end	
		end
	end
)


function createVehicleBlip( vehicle )
	if not vehicleBlips[vehicle] then
		setTimer(
			function( v )
				if isElement( v ) then
					vehicleBlips[v] = createBlipAttachedTo( v, 0, 1, 200, 200, 200, 80, 0 )
				end
			end,
		100, 1, vehicle )
	end
end


function destroyVehicleBlip( vehicle )
	if vehicleBlips[vehicle] then
		destroyElement( vehicleBlips[vehicle] )
		vehicleBlips[vehicle] = nil
	end
end