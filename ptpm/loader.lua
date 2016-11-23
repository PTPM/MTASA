-- possibly split this up into separate files for each map element (eg: tasks.lua, objectives.lua, etc)
-- and call the specific loading functions from here

-- compcheck
addEvent( "onGamemodeMapStart", false )
function ptpmMapStart( map )

	options = {}
	data = {}

	currentClass = {}
	currentPM = false
	
	classes = {}
	miniClass = {}
	randomSpawns = {}
	cantDrive = {}
	cantPassenger = {}
	cantPickup = {}
	
	if isRunning( "ptpm_login" ) then
		settings.loginActive = true
		if not settings.loginHandled then
			addEventHandler( "onResourceStop", getResourceRootElement( getResourceFromName( "ptpm_login" ) ), ptpmLoginResourceStop )
			settings.loginHandled = true
		end
		
		-- Send players that haven't logged in to login screen
		for _, v in ipairs( getElementsByType( "player" ) ) do
			if v and isElement( v ) and not getElementData( v, "ptpm.loggedIn" ) then
				exports.ptpm_login:setLoginScreenForPlayer( v )
			end
		end
	else
		settings.loginActive = false
	end
	
	runningMap = map
	runningMapRoot = source
	runningMapName = getResourceName( map )
	
	for _, v in ipairs( getElementsByType( "player" ) ) do
		if v and isElement( v ) and isPlayerActive( v ) then
			triggerClientEvent( v, "onClientMapStart", root, runningMapName )
		end
	end

	data.roundStartTime = getTickCount()
	
	options.boundariesEnabled = true
	
	options.roundtime = get( runningMapName .. ".roundtime" ) or 900000 -- 15 mins
	options.pmHealthBonus = get( runningMapName .. ".pmHealthBonus" ) or false
	options.medicHealthBonus = get( runningMapName .. ".medicHealthBonus" ) or false
	options.pocketMoney = get( runningMapName .. ".pocketMoney" ) or 500
	options.objectivesToFinish = get( runningMapName .. ".objectivesToFinish" ) or 5
	options.vehicleLaunch = get (runningMapName .. ".vehicleLaunch" ) or false	
	options.pmAbandonedHealthPenalty = get( runningMapName .. ".pmAbandonedHealthPenalty" ) or false
	options.mapType = get( runningMapName .. ".mapType" ) or "city"
	options.weathers = get( runningMapName .. ".weathers" ) or { 1, 2, 7, 9, 13, 17, 3, 11, 18, 5, 24 } -- city weathers	
	options.pmWaterDeath = get (runningMapName .. ".pmWaterDeath" ) or false	
	options.teamSpecificRadar = get( runningMapName .. ".teamSpecificRadar" ) or false	
	options.disableClouds = get( runningMapName .. ".disableClouds") or false
	options.vehicleHeightLimit = get( runningMapName .. ".vehicleHeightLimit") or false
	
	options.displayDistanceToPM = get( runningMapName .. ".displayDistanceToPM" ) or false	
	
	options.swapclass = {}
	
	
	if options.disableClouds then
		setCloudsEnabled( false )
	else
		setCloudsEnabled( true )
	end
	
	
	data.wardrobe = {}
	local warDrobeTable = getElementsByType( "wardrobe", runningMapRoot )
	if warDrobeTable and #warDrobeTable ~= 0 then
		for k, v in pairs( getAllElementData( warDrobeTable[1] ) ) do
			data.wardrobe[k] = tonumber(v)
		end
	else printConsole( "ERROR: No wardrobe in map "..runningMapName ) end
	
	
	-- intel
	
	
	data.safezone = {}
	local safezoneTable = getElementsByType( "safezone", runningMapRoot )
	for _, value in ipairs( safezoneTable ) do
		data.safezone[value] = {}
		data.safezone[value].exists = true
		data.safezone[value].posX = tonumber(getElementData( value, "posX" ))
		data.safezone[value].posY = tonumber(getElementData( value, "posY" ))
		data.safezone[value].posZ = tonumber(getElementData( value, "posZ" ))
		data.safezone[value].exclusion = tonumber(getElementData( value, "exclusion" ))
		data.safezone[value].enabled = (getElementData( value, "enabled" ) == "true")
		data.safezone[value].zone = createColSphere( data.safezone[value].posX, data.safezone[value].posY, data.safezone[value].posZ, data.safezone[value].exclusion/2)
		data.safezone[value].marker = createMarker( data.safezone[value].posX, data.safezone[value].posY, data.safezone[value].posZ, "cylinder", data.safezone[value].exclusion, 0, 0, 170, 128, root )
		data.safezone[value].blip = createBlip( data.safezone[value].posX, data.safezone[value].posY, data.safezone[value].posZ, 0, 3, 0, 0, 170, 255, 0, 200, root )
		setElementParent( data.safezone[value].marker, value )
		setElementParent( data.safezone[value].blip, value )
		setElementParent( data.safezone[value].zone, value )
		
		if not data.safezone[value].enabled then
			setElementVisibleTo ( data.safezone[value].marker, root, false )
			setElementVisibleTo ( data.safezone[value].blip, root, false )
		end
	end
	
	local classID = 1
	local spawnGroupTable = getElementsByType( "spawngroup", runningMapRoot )
	for _, value in ipairs( spawnGroupTable ) do
		local classType = getElementData( value, "type" )		
		for _, class in ipairs ( getElementsByType( "class", value ) ) do
		    --local classID = tonumber(getElementID(class))
			classes[classID] = {}
			classes[classID].type = classType
			classes[classID].skin = tonumber(getElementData(class, "skin"))
			-- maps can supply their own skin images if ptpm doesn't have them by adding a "ptpm-skins-ID.png" file to their root and setting hasImage="true" on the class definition
			classes[classID].mapSkinImage = (getElementData(class, "hasImage") == "true")
			classes[classID].weapons = commaPairedStringToTable(getElementData(class, "weapons"))
			classes[classID].medic = (getElementData( class, "medic" ) == "true")
			classes[classID].initialHP = tonumber(getElementData( class, "initialHP" )) or 100

			classID = classID + 1
		end
		
		randomSpawns[classType] = {}
		local count = 0
		for _, spawn in ipairs( getElementsByType( "spawn", value ) ) do
			randomSpawns[classType][count] = {}
			randomSpawns[classType][count].posX = tonumber(getElementData( spawn, "posX" ))
			randomSpawns[classType][count].posY = tonumber(getElementData( spawn, "posY" ))
			randomSpawns[classType][count].posZ = tonumber(getElementData( spawn, "posZ" ))
			randomSpawns[classType][count].rot = tonumber(getElementData( spawn, "rot" )) or tonumber(getElementData( spawn, "rotZ" ))
			randomSpawns[classType][count].interior = tonumber(getElementData( spawn, "interior" )) or 0
			
			count = count + 1
		end
		
		local lineSpawnTable = getElementsByType( "linespawn", value )
		for _, linespawn in ipairs( lineSpawnTable ) do
			local startX, startY, startZ = getElementData( linespawn, "startX" ), getElementData( linespawn, "startY" ), getElementData( linespawn, "startZ" )
			local endX, endY, endZ = getElementData( linespawn, "endX" ), getElementData( linespawn, "endY" ), getElementData( linespawn, "endZ" )
			local seperation, interior = getElementData( linespawn, "seperation" ) or 1.0, getElementData( linespawn, "interior" ) or 0
			local length = getDistanceBetweenPoints3D( startX, startY, startZ, endX, endY, endZ )
			
			if length < 1.0 then break end			
			local xv, yv, zv = (endX - startX)/length, (endY - startY)/length, (endZ - startZ)/length
			local grad, face_angle = math.abs(yv/xv)
			
			if xv >= 0 and yv >= 0 then face_angle = 90 - math.atan(grad)
			elseif xv >= 0 and yv < 0 then face_angle = 90 + math.atan(grad)
			elseif xv < 0 and yv < 0 then face_angle = 270 - math.atan(grad)
			elseif xv < 0 and yv >= 0 then face_angle = 270 + math.atan(grad)
			end
			
			face_angle = face_angle - 90.0
			if face_angle >= 360.0 then face_angle = face_angle - 360.0 end

			for i=0, length, seperation do
				local x, y, z, rot = startX+i*xv, startY+i*yv, startZ+i*zv, 360-face_angle
				randomSpawns[classType][count] = {}
				randomSpawns[classType][count].posX = x
				randomSpawns[classType][count].posY = y
				randomSpawns[classType][count].posZ = z
				randomSpawns[classType][count].rot = rot
				randomSpawns[classType][count].interior = interior
				count = count + 1
			end
		end
		
		cantDrive[classType] = {}
		for i=400, 612, 1 do
			cantDrive[classType][i] = false
		end
		
		local cantDriveTable = getElementsByType( "cantdrive", value )
		if cantDriveTable and #cantDriveTable ~= 0 then
			if getElementData( cantDriveTable[1], "models" ) == "any" then
				for i=400, 612, 1 do
					cantDrive[classType][i] = true
				end
			else
				local cantDriveTable2 = split( getElementData( cantDriveTable[1], "models" ), 44 )
				if cantDriveTable2 then
					for _, value2 in ipairs ( cantDriveTable2 ) do
						cantDrive[classType][tonumber(value2)] = true
					end
				end
			end
		end
		
		cantPassenger[classType] = {}
		for i=400, 612, 1 do
			cantPassenger[classType][i] = false
		end
		
		local cantPassengerTable = getElementsByType( "cantpassenger", value )
		if cantPassengerTable and #cantPassengerTable ~= 0 then
			if getElementData( cantPassengerTable[1], "models" ) == "any" then
				for i=400, 612, 1 do
					cantPassenger[classType][i] = true
				end
			else
				local cantPassengerTable2 = split( getElementData( cantPassengerTable[1], "models" ), 44 )
				if cantPassengerTable2 then
					for _, value2 in ipairs ( cantPassengerTable2 ) do
						cantPassenger[classType][tonumber(value2)] = true
					end
				end
			end
		end
		
		local cantPickupTable = getElementsByType( "cantpickup", value )
		if cantPickupTable and #cantPickupTable ~= 0 then
			if getElementData( cantPickupTable[1], "models" ) == "any" then
				cantPickup[classType] = {}
				for i=1, 45, 1 do
					cantPickup[classType][i] = true
				end
				--cantPickup[classType]["armor"] = true
			else
				local cantPickupTable2 = split( getElementData( cantPickupTable[1], "models" ), 44 )
				if cantPickupTable2 then
					cantPickup[classType] = {}
					for _, value2 in ipairs ( cantPickupTable2 ) do
						cantPickup[classType][tonumber(value2)] = true
					end
				end
			end
		end
	end
	
	
	for i = 1, #classes, 1 do
		miniClass[i] = classes[i] and classes[i].type or ""
	end
	
	
	data.tasks = {}
	local taskTable = getElementsByType( "task", runningMapRoot )
	for _, value in ipairs( taskTable ) do
		local taskType = getElementData( value, "type" )
		data.tasks[value] = {}
		data.tasks[value].type = taskType
		data.tasks[value].time = tonumber(getElementData( value, "time" )) or 60000
		data.tasks[value].taskArea = createColTube( tonumber(getElementData( value, "posX" )), tonumber(getElementData( value, "posY" )), tonumber(getElementData( value, "posZ" ))-(tonumber(getElementData( value, "size" ))/2), tonumber(getElementData( value, "size" ))/2, tonumber(getElementData( value, "size" )) )
		data.tasks[value].marker = createMarker( tonumber(getElementData( value, "posX" )), tonumber(getElementData( value, "posY" )), tonumber(getElementData( value, "posZ" )), "cylinder", tonumber(getElementData( value, "size" )), 170, 0, 0, 128, root )
		data.tasks[value].blip = createBlip( tonumber(getElementData( value, "posX" )), tonumber(getElementData( value, "posY" )), tonumber(getElementData( value, "posZ" )), 0, 3, 170, 0, 0, 255, 0, 200, root )
		data.tasks[value].desc = getElementData( value, "desc" ) or taskDesc[taskType]
		data.tasks[value].finishText = getElementData( value, "finishText" ) or taskFinishText[taskType]
		
	--	setElementVisibleTo ( data.tasks[value].marker, root, true )
	--	setElementVisibleTo ( data.tasks[value].blip, root, true )
		
		setElementParent( data.tasks[value].taskArea, value )
		setElementParent( data.tasks[value].marker, value )
		setElementParent( data.tasks[value].blip, value )
	end
	
	
	data.objectives = {}
	data.objectiveRandomizer = {}
	data.objectives.finished = 0
	
	local objectiveTable = getElementsByType( "objective", runningMapRoot )
	for i, value in ipairs( objectiveTable ) do
		data.objectives[value] = {}
		data.objectiveRandomizer[i] = value
		data.objectives[value].time = tonumber(getElementData( value, "time" )) or 30000
		data.objectives[value].objArea = createColSphere( tonumber(getElementData( value, "posX" )), tonumber(getElementData( value, "posY" )), tonumber(getElementData( value, "posZ" )), tonumber(getElementData( value, "size" ))*0.5 )
		data.objectives[value].marker = createMarker( tonumber(getElementData( value, "posX" )), tonumber(getElementData( value, "posY" )), tonumber(getElementData( value, "posZ" )), "cylinder", tonumber(getElementData( value, "size" )), 170, 0, 0, 128, root )
		data.objectives[value].blip = createBlip( tonumber(getElementData( value, "posX" )), tonumber(getElementData( value, "posY" )), tonumber(getElementData( value, "posZ" )), 0, 3, 170, 0, 0, 255, 0, 9999, root )
		data.objectives[value].desc = getElementData( value, "desc" ) or false
		
		setElementVisibleTo ( data.objectives[value].marker, root, false )
		setElementVisibleTo ( data.objectives[value].blip, root, false )
		
		setElementParent( data.objectives[value].objArea, value )
		setElementParent( data.objectives[value].marker, value )
		setElementParent( data.objectives[value].blip, value )
	end
	if #objectiveTable > 0 then setupNewObjective() end
	
	
	data.vehicleRespawn = {}
	data.vehicleRespawnTime = 60000
	
	local vehicleTable = getElementsByType( "vehicle", runningMapRoot )
	for _, value in ipairs( vehicleTable ) do
		setVehicleRespawnDelay( value, 10000 )
		toggleVehicleRespawn( value, true )
		
		data.vehicleRespawn[value] = {}
		data.vehicleRespawn[value].delay = data.vehicleRespawnTime
		
		if options.vehicleLaunch and getElementModel(value) == 476 then
			data.vehicleRespawn[value].launched = false
		end
		
		if getElementID(value) == "desert_crashed_plane" then
			setVehicleDamageProof(value,true)
			setVehicleLocked(value,true)
		end
	end
	
	
	data.pickups = {}
	local pickupTable = getElementsByType( "pickup", runningMapRoot )
	for _, value in ipairs( pickupTable ) do
		data.pickups[value] = {}
		data.pickups[value].synced = (getElementData( value, "synced" ) == "true")
		data.pickups[value].respawn = getPickupRespawnInterval( value ) ~= 9999999 and getPickupRespawnInterval( value ) or false
		data.pickups[value].destroy = (getElementData( value, "destroy" ) == "true")
		data.pickups[value].lastPickup = {}
	end
	
	
	data.boundaryCorners = {}
	local boundaryCornerTable = getElementsByType( "boundarycorner", runningMapRoot )
	for i, value in ipairs( boundaryCornerTable ) do
		data.boundaryCorners[i-1] = {}
		data.boundaryCorners[i-1].x = tonumber( getElementData( value, "posX" ) )
		data.boundaryCorners[i-1].y = tonumber( getElementData( value, "posY" ) )
		--createBlip( data.boundaryCorners[i-1].x, data.boundaryCorners[i-1].y, 0, 0, 1 )
	end
	
	if #data.boundaryCorners == 0 then
		data.boundaryCorners[0], data.boundaryCorners[1], data.boundaryCorners[2], data.boundaryCorners[3] = {}, {}, {}, {}
		data.boundaryCorners[0].x, data.boundaryCorners[0].y = -10000, -10000
		data.boundaryCorners[1].x, data.boundaryCorners[1].y = 10000, -10000
		data.boundaryCorners[2].x, data.boundaryCorners[2].y = 10000, 10000
		data.boundaryCorners[3].x, data.boundaryCorners[3].y = -10000, 10000
		printConsole( "No boundary corners. Loaded default boundaries." )
	end
	
	
	data.teleports = {}
	local teleportTable = getElementsByType( "teleport", runningMapRoot )
	for _, value in ipairs( teleportTable ) do
		data.teleports[value] = {}
		local minX, minY, minZ = tonumber( getElementData( value, "minX" ) ), tonumber( getElementData( value, "minY" ) ), tonumber( getElementData( value, "minZ" ) )
		local maxX, maxY, maxZ = tonumber( getElementData( value, "maxX" ) ), tonumber( getElementData( value, "maxY" ) ), tonumber( getElementData( value, "maxZ" ) )
		data.teleports[value].cuboid = createColCuboid( minX, minY, minZ, maxX-minX, maxY-minY, maxZ-minZ )
	--	createObject(1215,minX+((maxX-minX)/2),minY+((maxY-minY)/2),minZ+((maxZ-minZ)/2),0,0,0)	
		setElementParent( data.teleports[value].cuboid, value )
		data.teleports[value].message = getElementData( value, "message" ) or ""
		data.teleports[value].teleX = tonumber( getElementData( value, "teleX" ) )
		data.teleports[value].teleY = tonumber( getElementData( value, "teleY" ) )
		data.teleports[value].teleZ = tonumber( getElementData( value, "teleZ" ) )
		data.teleports[value].teleRot = tonumber( getElementData( value, "teleRot" ) )
		data.teleports[value].interior = tonumber( getElementData( value, "teleX" ) )
		data.teleports[value].vehicles = (getElementData( value, "vehicles" ) == "true")
		data.teleports[value].exitDimX = tonumber( getElementData( value, "exitDimX" ) ) or false
		data.teleports[value].exitDimY = tonumber( getElementData( value, "exitDimY" ) ) or false
	end
	
	
	data.securityCameras = {}
	local cameraTable = getElementsByType( "camera", runningMapRoot )
	for _, value in ipairs( cameraTable ) do
		local id = tonumber(getElementID( value ))
		data.securityCameras[id] = {}
		data.securityCameras[id].camX = tonumber(getElementData( value, "camX" ))
		data.securityCameras[id].camY = tonumber(getElementData( value, "camY" ))
		data.securityCameras[id].camZ = tonumber(getElementData( value, "camZ" ))
		data.securityCameras[id].pointX = tonumber(getElementData( value, "pointX" ))
		data.securityCameras[id].pointY = tonumber(getElementData( value, "pointY" ))
		data.securityCameras[id].pointZ = tonumber(getElementData( value, "pointZ" ))
	end
	
	
	data.cameraMounts = {}
	local cameraMountTable = getElementsByType( "cameraMount", runningMapRoot ) -- these are the _mount and _point in original ptpm
	for _, value in ipairs( cameraMountTable ) do
		data.cameraMounts[value] = {}
		data.cameraMounts[value].posX = tonumber(getElementData( value, "posX" ))
		data.cameraMounts[value].posY = tonumber(getElementData( value, "posY" ))
		data.cameraMounts[value].posZ = tonumber(getElementData( value, "posZ" ))
		data.cameraMounts[value].camera = createPickup( data.cameraMounts[value].posX, data.cameraMounts[value].posY, data.cameraMounts[value].posZ, 3, 1616, 30000, 1 )
		data.cameraMounts[value].message = getElementData( value, "message" ) or ""
		data.cameraMounts[value].usesIDs = split( getElementData( value, "usesIDs" ), 44 )
		data.cameraMounts[value].playerX = tonumber(getElementData( value, "playerX" ))
		data.cameraMounts[value].playerY = tonumber(getElementData( value, "playerY" ))
		data.cameraMounts[value].playerZ = tonumber(getElementData( value, "playerZ" ))
		setElementParent( data.cameraMounts[value].camera, value )
	end
	
	
	-- attaching objects causes problems (see http://remp.sparksptpm.co.uk/mta/attachment_jump.mp4)
	-- leave this out until its fixed
--[[	data.objects = {}
	data.objects.attachments = {}
	
	local objectTable = getElementsByType( "object", runningMapRoot )
	for _,o in ipairs( objectTable ) do
		local id = getElementData(o,"id")
		
		if id and id:find("attach") then		
			local pos, rot = {},{}
		
			pos.x, pos.y, pos.z = getElementData(o,"posX"),getElementData(o,"posY"),getElementData(o,"posZ")
			rot.x, rot.y, rot.z = getElementData(o,"rotX"),getElementData(o,"rotY"),getElementData(o,"rotZ")
			
			if not data.objects.attachments[id] then
				data.objects.attachments[id] = {}
				data.objects.attachments[id].ob = createObject(6976,pos.x,pos.y,pos.z,rot.x,rot.y,rot.z)	
				data.objects.attachments[id].pos = {x = pos.x, y = pos.y, z = pos.z}
				data.objects.attachments[id].rot = {x = rot.x, y = rot.y, z = rot.z} 
			end			

			-- cant use matrices, getElementMatrix is clientside only
			
			if data.objects.attachments[id] then
				attach(o,data.objects.attachments[id].ob,
						 pos.x,pos.y,pos.z,rot.x,rot.y,rot.z,
						 data.objects.attachments[id].pos.x,data.objects.attachments[id].pos.y,data.objects.attachments[id].pos.z,
						 data.objects.attachments[id].rot.x,data.objects.attachments[id].rot.y,data.objects.attachments[id].rot.z)
			end
		end
	end
]]	

	options.missionTimerCreatorTimer = setTimer(
		function()
			if not data.timer then
				data.timer = exports.missiontimer:createMissionTimer( options.roundtime-2000, true, "%m:%s", 0.5, 12, false, "pricedown", 1 )
				exports.missiontimer:setMissionTimerHurryTime( data.timer, 60000 )
				options.missionTimerCreatorTimer = nil
			end
		end,
	2000, 1 )
	

	printConsole( "Map loaded! It has: " 
						.. (#spawnGroupTable or 0) .. " spawngroups, "
						.. (#classes or 0) .. " classes, "
						.. (#taskTable or 0) .. " tasks, "
						.. (#objectiveTable or 0) .. " objectives, "
						.. (#vehicleTable or 0) .. " vehicles, "
					--	.. (#objectTable or 0) .. " objects, "
						.. (#pickupTable or 0) .. " pickups, "
						.. (#boundaryCornerTable or 0) .. " boundary corners, "
						.. (#teleportTable or 0) .. " teleports and "
						.. (#cameraTable or 0) .. " security cameras (" .. (#cameraMountTable or 0) .. " mounts)"
						.. "[" .. tostring(options.roundtime) .. "]"
				)

	setPedGravity( root, 0.008 )

	changeWeather()
	
	local currentPlayers = getElementsByType( "player" )
	options.playerPrepareTimer = setTimer( 	
		function( players ) 
			local realTime = getRealTime()
			for _, value in ipairs( players ) do
				-- Prepare active players (ignore the ones in login screen)
				if value and isElement( value ) and isPlayerActive( value ) then
					preparePlayer( value )
					triggerClientEvent( value, "onClientMapStarted", value, miniClass, options.displayDistanceToPM )
				
					initClassSelection( value )
				end
			end
			data.roundTimer = setTimer( roundTick, 1000, 0 )
			options.playerPrepareTimer = nil
		end,
	4000, 1, currentPlayers )
	
	--loadMapBots(map)

end
addEventHandler( "onGamemodeMapStart", root, ptpmMapStart )
-- compcheck
addEvent( "onGamemodeMapStop", false )
function ptpmMapStop( map )

	clearTask()
	clearObjective()

	for _, value in ipairs( getElementsByType( "task", source ) ) do
		if data.tasks and data.tasks[value] then
			if data.tasks[value].taskArea then destroyElement(data.tasks[value].taskArea) data.tasks[value].taskArea = nil end
			if data.tasks[value].marker then destroyElement(data.tasks[value].marker) data.tasks[value].marker = nil end
			if data.tasks[value].blip then destroyElement(data.tasks[value].blip) data.tasks[value].blip = nil end
		end
	end		
	
	for _, value in pairs( getElementsByType( "safezone", source ) ) do
		if data.safezone and data.safezone[value] then
			if data.safezone[value].marker then destroyElement(data.safezone[value].marker) data.safezone[value].marker = nil end
			if data.safezone[value].blip then destroyElement(data.safezone[value].blip) data.safezone[value].blip = nil end
			if data.safezone[value].zone then destroyElement(data.safezone[value].zone) data.safezone[value].zone = nil end
		end
	end
	
	for _, value in pairs( getElementsByType( "teleport", source ) ) do
		if data.teleports and data.teleports[value] then
			if data.teleports[value].cuboid then destroyElement(data.teleports[value].cuboid) data.teleports[value].cuboid = nil end
		end
	end
	
	for _, value in ipairs( getElementsByType( "objective", source ) ) do
		if data.objectives and data.objectives[value] then
			if data.objectives[value].objArea then destroyElement(data.objectives[value].objArea) data.objectives[value].objArea = nil end
			if data.objectives[value].marker then destroyElement(data.objectives[value].marker) data.objectives[value].marker = nil end
			if data.objectives[value].blip then destroyElement(data.objectives[value].blip) data.objectives[value].blip = nil end
		end
	end
	
	-- Destroy jetpacks & their timers
	if data.pickup then
		for value, _ in pairs( data.pickups ) do
			if data.pickups[value].timer then
				destroyPickup( value )
			end
		end
	end
	
	-- Destroy vehicle respawn timers
	for _, vehicle in ipairs( getElementsByType( "vehicle" ) ) do
		if vehicle and isElement( vehicle ) then
			stopVehicleRespawn( vehicle )
		end
	end

	for _, value in ipairs( getElementsByType( "player" ) ) do
		if value and isElement( value ) then
		--if playerInfo then
		--	if playerInfo[value] then
				--playerInfo[value].class = nil <- doesn't remove class
				resetPlayerRound( value )
				-- Following are in resetPlayerRound()
				-- classSelectionRemove( value )
				-- local activeCamera = getElementData( value, "ptpm.activeCamera" )
				-- if activeCamera then
				-- --if playerInfo[value].activeCamera then
					-- clearCameraFor( value )	
				-- end
				-- setPlayerTeam( value, nil )
				-- setElementData( value, "ptpm.score.class", nil )
					
				triggerClientEvent( value, "onClientMapStop", root, runningMapName )
		--	end
		end
	end
	
	if data.roundTimer then
		if isTimer( data.roundTimer ) then
			killTimer( data.roundTimer )
		end
		data.roundTimer = nil
	end
	
	if options.swapclass and options.swapclass.target then
		if options.swapclass.timer then
			if isTimer( options.swapclass.timer ) then
				killTimer( options.swapclass.timer )
			end
		end
		drawStaticTextToScreen( "delete", options.swapclass.target, "swapText" )
		options.swapclass = {}
	end
	
	currentPM = false
	
	if options.missionTimerCreatorTimer then
		if isTimer( options.missionTimerCreatorTimer ) then
			killTimer( options.missionTimerCreatorTimer )
		end
		options.missionTimerCreatorTimer = nil
	end
	
	if options.playerPrepareTimer then
		if isTimer( options.playerPrepareTimer ) then
			killTimer( options.playerPrepareTimer )
		end
		options.playerPrepareTimer = nil
	end
	
	if options.endGamePrepareTimer then
		if isTimer( options.endGamePrepareTimer ) then
			killTimer( options.endGamePrepareTimer )
		end
		options.endGamePrepareTimer = nil
	end
	
	if data.timer then
		if isElement( data.timer ) then
			destroyElement( data.timer )
		end
		data.timer = nil
	end
	
	--drawStaticTextToScreen( "delete", root, "roundTimer" )
end
addEventHandler( "onGamemodeMapStop", root, ptpmMapStop )


function ptpmLoginResourceStop( resource )
	removeEventHandler( "onResourceStop", getResourceRootElement( resource ), ptpmLoginResourceStop )
	settings.loginActive = nil
	settings.loginHandled = nil
end

function resetPlayer( thePlayer )
	resetPlayerRound( thePlayer )
	
	-- Save session lengths
	if isRunning( "ptpm_accounts" ) then
		local now = getRealTime().timestamp
		local sessionjoin = getElementData( thePlayer, "ptpm.sessionjoin" ) or now
		local sessionlength = now - sessionjoin
		
		local timeplaying = exports.ptpm_accounts:getPlayerStatistic( thePlayer, "timeplaying" ) or 0
		exports.ptpm_accounts:setPlayerStatistic( thePlayer, "timeplaying", timeplaying + sessionlength )
		
		local longestsession = exports.ptpm_accounts:getPlayerStatistic( thePlayer, "longestsession" ) or 0
		if sessionlength > longestsession then
			exports.ptpm_accounts:setPlayerStatistic( thePlayer, "longestsession", sessionlength )
		end
	end
	
	-- Save player stats
	local username = getPlayerUsername( thePlayer )
	if username then
		exports.ptpm_accounts:savePlayerStats( thePlayer, username )
	end
	
	setElementData( thePlayer, "ptpm.ready", nil, false )
	-- setElementData( thePlayer, "ptpm.loggedIn", nil ) -- This is handled by ptpm_login
	-- setElementData( thePlayer, "ptpm.loggingIn", nil ) -- This is handled by ptpm_login
	
	local freezeTimer = getElementData( thePlayer, "ptpm.freezeTimer" )
	if freezeTimer then
		if isTimer( freezeTimer ) then
			killTimer( freezeTimer )
		end
	end
	setElementData( thePlayer, "ptpm.freezeTimer", nil, false ) -- NOTE: add check to spawn for being frozen
	setElementData( thePlayer, "ptpm.controllable", nil, false ) -- setPlayerControllable toggles

	local muteTimer = getElementData( thePlayer, "ptpm.muteTimer" )
	if muteTimer then
		if isTimer( muteTimer ) then
			killTimer( muteTimer )
		end
	end
	setElementData( thePlayer, "ptpm.muteTimer", nil, false )

	setElementData( thePlayer, "ptpm.score.kills", nil )
	setElementData( thePlayer, "ptpm.score.deaths", nil )
	
	setElementData( thePlayer, "ptpm.id", nil )
	setElementData( thePlayer, "ptpm.sessionjoin", nil, false )
end

function resetPlayerRound( thePlayer )
	-- Round specific info should be reset
	setElementData( thePlayer, "ptpm.classID", nil )
	
	local watching = getElementData( thePlayer, "ptpm.watching" )
	if watching then
		exports.spectator:spectateStop( thePlayer )
	end
	setElementData( thePlayer, "ptpm.watching", nil, false )
	
	local activeCamera = getElementData( thePlayer, "ptpm.activeCamera" )
	if activeCamera then
		clearCameraFor( thePlayer )
	end
	setElementData( thePlayer, "ptpm.activeCamera", nil, false )
	setElementData( thePlayer, "ptpm.currentCameraID", nil, false )
	local gettingOffCamera = getElementData( thePlayer, "ptpm.gettingOffCamera" )
	if gettingOffCamera then
		if isTimer( gettingOffCamera ) then
			killTimer( gettingOffCamera )
		end
	end
	setElementData( thePlayer, "ptpm.gettingOffCamera", nil, false )
	
	local inClassSelection = getElementData( thePlayer, "ptpm.inClassSelection" )
	if inClassSelection then
		classSelectionRemove( thePlayer )
	end
	setElementData( thePlayer, "ptpm.inClassSelection", nil, false )
	setElementData( thePlayer, "ptpm.classSelect.id", nil, false )
	setElementData( thePlayer, "ptpm.classSelect.lctrl", nil, false )
	setElementData( thePlayer, "ptpm.classSelect.rctrl", nil, false )
	
	local autoRight = getElementData( thePlayer, "ptpm.classSelect.autoRight" )
	if autoRight then
		if isTimer( autoRight ) then
			killTimer( autoRight )
		end
	end
	setElementData( thePlayer, "ptpm.classSelect.autoRight", nil, false )
	
	local autoLeft = getElementData( thePlayer, "ptpm.classSelect.autoLeft" )
	if autoLeft then
		if isTimer( autoLeft ) then
			killTimer( autoLeft )
		end
	end
	setElementData( thePlayer, "ptpm.classSelect.autoLeft", nil, false )
	
	setElementData( thePlayer, "ptpm.classSelectAfterDeath", nil, false )
	
	local interiorBlip = getElementData( thePlayer, "ptpm.interiorBlip" )
	if interiorBlip then
		destroyElement( interiorBlip )
	end	
	setElementData( thePlayer, "ptpm.interiorBlip", nil, false )
	
	local pinfoTimer = getElementData( thePlayer, "ptpm.pinfoTimer" )
	if pinfoTimer then
		if isTimer( pinfoTimer ) then
			killTimer( pinfoTimer )
		end
		drawStaticTextToScreen( "delete", thePlayer, "pinfo" )
	end
	setElementData( thePlayer, "ptpm.pinfoTimer", nil, false )
	
	setElementData( thePlayer, "ptpm.goodX", nil, false )
	setElementData( thePlayer, "ptpm.goodY", nil, false )
	setElementData( thePlayer, "ptpm.goodZ", nil, false )
	
	setElementData( thePlayer, "ptpm.consecutiveKills", nil, false )
	setElementData( thePlayer, "ptpm.roundKills", nil, false )
	setElementData( thePlayer, "ptpm.currentInterior", nil, false )
	
	local afterDeathTimer = getElementData( thePlayer, "ptpm.afterDeathTimer" )
	if afterDeathTimer then
		if isTimer( afterDeathTimer ) then
			killTimer( afterDeathTimer )
		end
	end
	setElementData( thePlayer, "ptpm.afterDeathTimer", nil, false )
	
	removePlayerBlip( thePlayer )
	setElementData( thePlayer, "ptpm.blip.visibleto", nil )
	
	setElementData( thePlayer, "ptpm.score.class", nil )
	
	setPlayerTeam( thePlayer, nil )
end

function preparePlayer( thePlayer )
	setElementData( thePlayer, "ptpm.classSelect.id", 1, false )
	--setPlayerControllable( thePlayer, true ) -- Element data is false by default, but this is reset to false in class selection anyway
end