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
local settings = {}


addEvent("doWarpPlayerToInterior", true)
addEvent("onClientInteriorHit")
addEvent("onClientInteriorWarped")
addEvent("updateClientSettings", true)
addEvent("playerLoadingGround", true)


addEventHandler("onClientResourceStart", root,
	function(resource)
		triggerServerEvent("onClientReady", localPlayer)

		interiorLoadElements(getResourceRootElement(resource), resource)
		interiorCreateColliders(resource)		
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
		end
	end
end


function colshapeHit(player, matchingDimension)
	if (not isElement(player)) or getElementType(player) ~= "player" or player ~= localPlayer then 
		return 
	end

	if (not matchingDimension) or isPedInVehicle(player) or doesPedHaveJetPack(player) or (not isPedOnGround(player)) or 
		getControlState("aim_weapon") or (not allowPlayerToTeleport) or (source == targetCollider) then 
		return 
	end

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

		-- just in case the teleport event is cancelled by the server (and won't be cleared when we check for ground loading)
		-- we'll clear this anyway after a few seconds
		setTimer(
			function()
				targetCollider = nil
			end,
		2000, 1)
	end
end


addEventHandler("playerLoadingGround", localPlayer,
	function(interior)
		allowPlayerToTeleport = false

		pauseUntilWorldHasLoaded(triggerGroundLoaded, interior)
	end
)

function pauseUntilWorldHasLoaded(fn, ...)
	local x, y, z = getElementPosition(localPlayer)
	
	if loadingTimer and isTimer(loadingTimer) then
		return
	end

	-- save the original gravity
	local savedGravity

	savedGravity = getGravity()
	--setGravity(0)

	local attempts = 0
	local foundGround = false
	
	-- call the function once the environment has loaded
	loadingTimer = setTimer(
		function(arguments)
			-- hard limit to use as a fallback in case we can't detect a collision
			attempts = attempts + 1
			
			local x, y = getElementPosition(localPlayer)

			if attempts > 40 or foundGround then
				--outputDebugString("pauseUntilWorldHasLoaded loaded after " .. tostring(attempts) .. " attempts")
			
				if savedGravity and getGravity() == 0 then
					--setGravity(savedGravity)
				end
				
				if type(fn) == "function" then
					fn(unpack(arguments))
				end
				
				killTimer(loadingTimer)
				loadingTimer = nil
			end
			
			-- ground has loaded, set that we are done so the timer ticks once more before breaking
			-- this gives us a 100ms grace period
			if (not isLineOfSightClear(x, y, z + 5, x, y, z - 5, true, false, false, true, false, true, false, localPlayer)) then
				foundGround = true
			end
		end, 
	100, 0, {...})
end

function triggerGroundLoaded(interior) 
	triggerServerEvent("onPlayerGroundLoaded", localPlayer, interior)

	allowPlayerToTeleport = true
	targetCollider = nil

 	triggerEvent("onClientInteriorWarped", interior)
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
		outputDebugString("getInteriorName: Invalid variable specified as interior.  Element expected, got " .. type(interior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local interiorType = getElementType(interior)

	if looksups.idDataName[interiorType] then
		return getElementData(interior, lookups.idDataName[interiorType])
	else
		outputDebugString("getInteriorName: Bad element specified.  Interior expected, got " .. interiorType .. ".", 0, unpack(outputColour))
		return false
	end
end