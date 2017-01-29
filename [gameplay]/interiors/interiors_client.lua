-- local interiorAnims = {}
-- local setInteriorMarkerZ = {
-- 	interiorEntry = 
-- 		function(marker, z)
-- 			local interiorElement = getElementParent(marker)
-- 			local vx = getElementData(interiorElement, "posX")
-- 			local vy = getElementData(interiorElement, "posY")
-- 			local vz = getElementData(interiorElement, "posZ")
-- 			--
-- 		 	setElementPosition(marker, vx, vy, vz + z/2 + 2.4)
-- 		end,
-- 	interiorReturn = 
-- 		function(marker, z)
-- 			local interiorElement = getElementParent(marker)
-- 			local vx = getElementData(interiorElement, "posX")
-- 			local vy = getElementData(interiorElement, "posY")
-- 			local vz = getElementData(interiorElement, "posZ")
-- 			--
-- 		 	setElementPosition(marker, vx, vy, vz + z/2 + 2.4)	
-- 		end
-- }


-- addEventHandler("onClientElementStreamIn",getRootElement(),
	-- function()
		-- if getElementType ( source ) == "marker" then
			-- local parent = getElementParent ( source ) 
			-- local parentType = getElementType(parent)
			-- if parentType == "interiorEntry" or parentType == "interiorReturn" then
				-- interiorAnims[source] = Animation.createAndPlay(
		-- source,
 		-- { from = 0, to = 2*math.pi, time = 2000, repeats = 0, transform = math.sin, fn = setInteriorMarkerZ[parentType] }
-- )
			-- end
		-- end
	-- end
-- )

-- addEventHandler("onClientElementStreamOut",getRootElement(),
	-- function()
		-- if getElementType ( source ) == "marker" then
			-- local parent = getElementParent ( source ) 
			-- local parentType = getElementType(parent)
			-- if parentType == "interiorEntry" or parentType == "interiorReturn" then
				-- if (interiorAnims[source] ) then
					-- interiorAnims[source]:remove()
				-- end
			-- end
		-- end
	-- end
-- )

local debugLog = {}
local debugLogEnabled = false
local debugLogPreviousTick = 0

addCommandHandler("intlog", 
	function(cmd)
		debugLogEnabled = not debugLogEnabled
		outputChatBox("Interior debug log " .. (debugLogEnabled and "enabled" or "disabled"))
	end
)

addCommandHandler("intdump",
	function(cmd)
		if not debugLogEnabled then
			outputChatBox("Interior debug log is not enabled, /intlog to enable")
			return
		end

		if #debugLog == 0 then
			outputChatBox("Interior debug log is empty")
			return
		end

		local debugFile = fileCreate("interiordebug_" ..tostring(getTickCount())..".txt")
		if debugFile then
			fileWrite(debugFile, unpack(debugLog))
			fileClose(debugFile)
			outputChatBox("Interior debug output to: interiordebug_"..tostring(getTickCount())..".txt")
		else
			outputChatBox("Interior debug could not create file")
		end
	end
)

function debugHook(...)
	if not debugLogEnabled then
		return
	end

	local logString = getTickCount() .. "[+" .. tostring(getTickCount() - debugLogPreviousTick) .."]: " .. 
						table.concat(arg, ", ") .. 
						", int:" .. tostring(getElementInterior(localPlayer)) .. 
						", dim:" .. tostring(getElementDimension(localPlayer)) ..
						"\r\n"

	table.insert(debugLog, logString)

	if #debugLog > 100 then
		table.remove(debugLog, 1)
	end

	debugLogPreviousTick = getTickCount()
end


local interiors = {}
local lookups = {
	colliders = {},
	resources = {},
	interiorFromCollider = {},

	opposite = { 
		["interiorReturn"] = "entry",
		["interiorEntry"] = "return" 
	},
	idDataName = { 
		["interiorReturn"] = "refid",
		["interiorEntry"] = "id"
	}
}

local outputColour = {255, 128, 0}
local allowPlayerToTeleport = true
local targetCollider = nil
local immunityTimer = nil
local leaveTimer = nil
local settings = {}
local offset = {
	xVariance = 0.8,
	yVariance = 0.8
}

addEvent("onClientInteriorHit")
addEvent("onClientInteriorWarped")
addEvent("updateClientSettings", true)
addEvent("playerLoadingGround", true)
addEvent("onPlayerInteriorHitCancelled", true)
addEvent("doWarpPlayerToInterior", true)

addEventHandler("onClientResourceStart", root,
	function(resource)
		if getResourceRootElement(resource) == resourceRoot then
			triggerServerEvent("onClientReady", resourceRoot)
		end

		interiorLoadElements(getResourceRootElement(resource), resource)
		interiorCreateColliders(resource)	

		debugHook("res-start", getResourceName(resource))	
	end 
)

addEventHandler("onClientResourceStop", root,
	function(resource)
		if not interiors[resource] then 
			return 
		end

		for id, interiorTable in pairs(interiors[resource]) do
			local entryCollider = lookups.colliders[interiorTable["entry"]]
			local returnCollider = lookups.colliders[interiorTable["return"]]

			if entryCollider then
				destroyElement(entryCollider)
			end

			if returnCollider then
				destroyElement(returnCollider)
			end
		end

		interiors[resource] = nil

		debugHook("res-stop", getResourceName(resource))
	end 
)


addEventHandler("updateClientSettings", root, 
	function(newSettings)
		if newSettings then
			settings = newSettings
		end
	end
)

function interiorLoadElements(rootElement, resource)
	---Load the exterior markers
	local entryInteriors = getElementsByType("interiorEntry", rootElement)
	for key, interior in pairs (entryInteriors) do
		if not interiors[resource] then 
			interiors[resource] = {} 
		end

		local id = getElementData(interior, "id")

		if not id then 
			outputDebugString("Interiors: Error, no ID specified on entryInterior.  Trying to load anyway.", 2)
		end

		interiors[resource][id] = {}
		interiors[resource][id]["entry"] = interior
		lookups.resources[interior] = resource
	end

	--Load the interior markers
	local returnInteriors = getElementsByType("interiorReturn", rootElement)
	for key, interior in pairs (returnInteriors) do
		local id = getElementData(interior, "refid")

		if not interiors[resource][id] then 
			outputDebugString("Interiors: Error, no refid specified to returnInterior.", 1)
		else
			interiors[resource][id]["return"] = interior
			lookups.resources[interior] = resource
		end
	end
end

function interiorCreateColliders(resource)
	if not interiors[resource] then 
		return 
	end

	for interiorID, interiorTypeTable in pairs(interiors[resource]) do
		-- create entry colliders
		local entryInterior = interiorTypeTable["entry"]
		local entX, entY, entZ = tonumber(getElementData(entryInterior, "posX")), tonumber(getElementData(entryInterior, "posY")), tonumber(getElementData(entryInterior, "posZ"))
		local dimension = tonumber(getElementData(entryInterior, "dimension")) or 0
		local interior = tonumber(getElementData(entryInterior, "interior")) or 0

		local col = createColSphere(entX, entY, entZ, 1.5)
		setElementParent(col, entryInterior)
		setElementInterior ( col, interior )
		setElementDimension ( col, dimension )

		lookups.colliders[entryInterior] = col
		lookups.interiorFromCollider[col] = entryInterior
		addEventHandler("onClientColShapeHit", col, colshapeHit) 
		--addEventHandler("onClientColShapeLeave", col, colShapeLeave)

		---create return colliders
		local returnInterior = interiorTypeTable["return"]
		
		if getElementData(entryInterior, "oneway" ) ~= "true" then 
			entX, entY, entZ = tonumber(getElementData(returnInterior, "posX")), tonumber(getElementData(returnInterior, "posY")), tonumber(getElementData(returnInterior, "posZ"))
			dimension = tonumber(getElementData(returnInterior, "dimension")) or 0
			interior = tonumber(getElementData(returnInterior, "interior")) or 0

			col = createColSphere(entX, entY, entZ, 1.5)

			setElementParent(col, returnInterior)
			setElementInterior(col, interior)
			setElementDimension(col, dimension)

			lookups.interiorFromCollider[col] = returnInterior
			lookups.colliders[returnInterior] = col
			addEventHandler("onClientColShapeHit", col, colshapeHit) 
			--addEventHandler("onClientColShapeLeave", col, colShapeLeave)
		end
	end
end

-- function colShapeLeave(player, matchingDimension)
-- 	if (not isElement(player)) or getElementType(player) ~= "player" or player ~= localPlayer then 
-- 		return 
-- 	end		

-- 	if not matchingDimension then
-- 		return
-- 	end

-- 	debugHook("colShapeLeave("..tostring(getInteriorName(lookups.interiorFromCollider[source]))..")", "col:" .. tostring(source), "target:" .. tostring(targetCollider))

-- 	if source == targetCollider then
-- 		targetCollider = nil
-- 	end	
-- end

function colshapeHit(player, matchingDimension)
	if (not isElement(player)) or getElementType(player) ~= "player" or player ~= localPlayer then 
		return 
	end

	if (not matchingDimension) or isPedInVehicle(player) or doesPedHaveJetPack(player) or (not isPedOnGround(player)) or 
		getControlState("aim_weapon") or (not allowPlayerToTeleport) or (source == targetCollider) then 
		if matchingDimension then
			debugHook("colShapeHit-cancel("..tostring(getInteriorName(lookups.interiorFromCollider[source]))..")", "col:" .. tostring(source), "target:" .. tostring(targetCollider), "allow:" .. tostring(allowPlayerToTeleport))
		end

		return 
	end
	--outputDebugString(getElementType(player) .. " hit " .. tostring(source) .. " (dim: " .. tostring(matchingDimension) .. ")")
	debugHook("colShapeHit("..tostring(getInteriorName(lookups.interiorFromCollider[source]))..")", "col:" .. tostring(source), "target:" .. tostring(targetCollider))

	local interior = lookups.interiorFromCollider[source]
	local id = getElementData(interior, lookups.idDataName[getElementType(interior)]) 
	local resource = lookups.resources[interior]

	local eventNotCancelled = triggerEvent("onClientInteriorHit", interior)
	if eventNotCancelled then
 		local oppositeType = lookups.opposite[getElementType(interior)]
 		local targetInterior = interiors[resource][id][oppositeType]

 		-- save the target collider so when we hit it we can ignore the event
		targetCollider = lookups.colliders[targetInterior]

		triggerServerEvent("doTriggerServerEvents", localPlayer, interior, getResourceName(resource), id)
		allowPlayerToTeleport = false
		debugHook("colShapeHit-passed("..tostring(getInteriorName(lookups.interiorFromCollider[source]))..")", "col:" .. tostring(source), "target:" .. tostring(targetCollider))
	end
end

addEventHandler("onPlayerInteriorHitCancelled", localPlayer,
	function(interior)
		debugHook("onPlayerInteriorHitCancelled("..tostring(getInteriorName(interior))..")", "col:" .. tostring(lookups.colliders[interior]), "target:" .. tostring(targetCollider))
		targetCollider = nil
		allowPlayerToTeleport = true
	end
)

addEventHandler("doWarpPlayerToInterior", localPlayer,
	function(interior, resource, id)
		local oppositeType = lookups.opposite[getElementType(interior)]
		local targetInterior = interiors[getResourceFromName(resource) or getThisResource()][id][oppositeType]

		local x = tonumber(getElementData(targetInterior, "posX"))
		local y = tonumber(getElementData(targetInterior, "posY"))
		local z = tonumber(getElementData(targetInterior, "posZ")) + 1
		local dim = tonumber(getElementData(targetInterior, "dimension"))
		local int = tonumber(getElementData(targetInterior, "interior"))
		local rot = tonumber(getElementData(targetInterior, "rotation"))

		if (not x) or (not y) or (not z) or (not dim) or (not int) or (not rot) then
			outputDebugString(string.format("setPlayerInsideInterior: Invalid warp data: %s %s %s %s %s %s", tostring(x), tostring(y), tostring(z), tostring(dim), tostring(int), tostring(rot)), 0, unpack(outputColour))
			return
		end	

		debugHook("doWarpPlayerToInterior("..tostring(getInteriorName(interior))..")", "col:" .. tostring(lookups.colliders[interior]), "target:" .. tostring(targetCollider))	
	
		toggleAllControls(false, true, false)
		fadeCamera(false, 1)

		-- this is the first point we can be sure we are being teleported
		allowPlayerToTeleport = false
		teleportImmunityActive = true

		if immunityTimer and isTimer(immunityTimer) then
			killTimer(immunityTimer)
			immunityTimer = nil
		end

		setTimer(setPlayerInsideInterior, 1000, 1, int, dim, rot, x, y, z, interior, targetInterior)
	end
)

function setPlayerInsideInterior(int, dim, rot, x, y, z, interior, targetInterior)
	debugHook("setPlayerInsideInterior("..tostring(getInteriorName(interior))..")", "col:" .. tostring(lookups.colliders[interior]), "target:" .. tostring(targetCollider))

	setElementRotation(localPlayer, 0, 0, rot % 360, "default", true)

	setTimer(
		function(p) 
			if isElement(p) then 
				setCameraTarget(p) 
			end 
		end, 
	200, 1, localPlayer)

	if settings.offsetTeleportPosition then
		-- some markers are in such small locations you can't safely offset the position e.g. the tower in sf
		local preventOffset = getElementData(targetInterior, "preventOffset")

		if not preventOffset then
			x, y, z = getAdjustedPosition(x, y, z, rot)
		end
	end

	
	setElementInterior(localPlayer, int)
	setCameraInterior(int)
	setElementDimension(localPlayer, dim)
	--setElementFrozen(localPlayer, true)
	setElementPosition(localPlayer, x, y, z)

	pauseUntilWorldHasLoaded({x = x, y = y, z = z}, triggerGroundLoaded, interior, x, y, z)
end

-- adjust the position slightly forward and to either side
function getAdjustedPosition(x, y, z, rot)
	local m = Matrix(Vector3(x, y, z), Vector3(0, 0, rot))

	local position = m:transformPosition(Vector3((math.random() * offset.xVariance) - (offset.xVariance / 2), math.random() * offset.yVariance, 0))

	return position:getX(), position:getY(), position:getZ()
end

-- addEventHandler("playerLoadingGround", localPlayer,
-- 	function(interior, posX, posY, posZ)
-- 		-- this is the first point we can be sure we are being teleported
-- 		allowPlayerToTeleport = false
-- 		teleportImmunityActive = true

-- 		if immunityTimer and isTimer(immunityTimer) then
-- 			killTimer(immunityTimer)
-- 			immunityTimer = nil
-- 		end

-- 		pauseUntilWorldHasLoaded({x = posX, y = posY, z = posZ}, triggerGroundLoaded, interior)

-- 		debugHook("playerLoadingGround("..tostring(getInteriorName(interior))..")", "target:" .. tostring(targetCollider))
-- 	end
-- )

function pauseUntilWorldHasLoaded(data, fn, ...)
	if loadingTimer and isTimer(loadingTimer) then
		return
	end

	local attempts = 0
	local foundGround = false
	
	-- call the function once the environment has loaded
	loadingTimer = setTimer(
		function(arguments)
			-- hard limit to use as a fallback in case we can't detect a collision
			attempts = attempts + 1
			
			if attempts > 30 or foundGround then
				--outputDebugString("pauseUntilWorldHasLoaded loaded after " .. tostring(attempts) .. " attempts")
				debugHook("pauseUntilWorldHasLoaded loaded", "attempts:" .. tostring(attempts), "target:" .. tostring(targetCollider))
				if type(fn) == "function" then
					fn(unpack(arguments))
				end
				
				killTimer(loadingTimer)
				loadingTimer = nil
			end
			
			-- ground has loaded, set that we are done so the timer ticks once more before breaking
			-- this gives us a 100ms grace period
			-- args: start x, y, z, end x, y, z, checkBuildings, checkVehicles, checkPeds, checkObjects, checkDummies, seeThroughStuff, ignoreSomeObjectsForCamera, ignoredElement
			if (not isLineOfSightClear(data.x, data.y, data.z + 1, data.x, data.y, data.z - 5, true, false, false, true, false, true, false, localPlayer)) then
				foundGround = true
			else
				setElementPosition(localPlayer, data.x, data.y, data.z)
			end
		end, 
	100, 0, {...})
end

function triggerGroundLoaded(interior, x, y, z) 
	allowPlayerToTeleport = true

	--outputDebugString("loaded: inside " ..tostring(targetCollider).. " " ..tostring(isElementWithinColShape(localPlayer, targetCollider)))
	--targetCollider = nil
	if leaveTimer and isTimer(leaveTimer) then
		killTimer(leaveTimer)
	end

	leaveTimer = setTimer(colliderLeaveCustom, 100, 0, x, y, z)

	toggleAllControls(true, true, false)	

	--setElementFrozen(localPlayer, false)

	fadeCamera(true, 1)

 	triggerEvent("onClientInteriorWarped", interior)
	triggerServerEvent("onInteriorWarped", interior, localPlayer)
	triggerServerEvent("onPlayerInteriorWarped", localPlayer, interior)

	if immunityTimer and isTimer(immunityTimer) then
		killTimer(immunityTimer)
		immunityTimer = nil
	end

 	immunityTimer = setTimer(
 		function()
 			teleportImmunityActive = false
 			immunityTimer = nil
 		end,
 	settings.teleportImmunityLength, 1)

 	debugHook("triggerGroundLoaded("..tostring(getInteriorName(interior))..")", "col:" .. tostring(lookups.colliders[interior]), "target:" .. tostring(targetCollider))
end

function colliderLeaveCustom(x, y, z)
	local px, py, pz = getElementPosition(localPlayer, x, y, z)

	if getDistanceBetweenPoints3D(px, py, pz, x, y, z) > 2 then
		targetCollider = nil
		killTimer(leaveTimer)
		leaveTimer = nil
	end
end

function getInteriorMarker(elementInterior)
	if not isElement(elementInterior) then 
		outputDebugString("getInteriorMarker: Invalid variable specified as interior. Element expected, got " .. type(elementInterior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local interiorType = getElementType(elementInterior)
	if interiorType == "interiorEntry" or interiorType == "interiorReturn" then
		return interiorMarkers[elementInterior] or false
	end

	outputDebugString("getInteriorMarker: Bad element specified. Interior expected, got " .. interiorType .. ".", 0, unpack(outputColour))
	return false
end

function getInteriorName(interior)
	if not isElement(interior) then 
		outputDebugString("getInteriorName: Invalid variable specified as interior. Element expected, got " .. type(interior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local interiorType = getElementType(interior)

	if lookups.idDataName[interiorType] then
		return getElementData(interior, lookups.idDataName[interiorType])
	else
		outputDebugString("getInteriorName: Bad element specified. Interior expected, got " .. interiorType .. ".", 0, unpack(outputColour))
		return false
	end
end


addEventHandler("onClientPlayerChoke", localPlayer, 
	function(weaponID, responsiblePed)
		if settings.immuneWhileTeleporting and teleportImmunityActive then
			cancelEvent()
		end
	end
)

addEventHandler("onClientPlayerDamage", localPlayer,
	function(attacker)
		if settings.immuneWhileTeleporting and teleportImmunityActive then
			cancelEvent()
		end
	end
)