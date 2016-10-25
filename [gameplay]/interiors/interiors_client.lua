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
	coliders = {},
	resources = {},
	interiorFromColider = {},

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
local allowPlayerTeleporting = true
local settings = {}


addEvent("doWarpPlayerToInterior", true)
addEvent("onClientInteriorHit")
addEvent("onClientInteriorWarped")
addEvent("updateClientSettings", true)


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
			local entryCollider = lookups.coliders[interiorTable["entry"]]
			local returnCollider = lookups.coliders[interiorTable["return"]]

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
		-- create entry coliders
		local entryInterior = interiorTypeTable["entry"]
		local entX, entY, entZ = tonumber(getElementData(entryInterior, "posX")), tonumber(getElementData(entryInterior, "posY")), tonumber(getElementData(entryInterior, "posZ"))
		local dimension = tonumber(getElementData(entryInterior, "dimension")) or 0
		local interior = tonumber(getElementData(entryInterior, "interior")) or 0

		local col = createColSphere(entX, entY, entZ, 1.5)
		setElementParent(col, entryInterior)
		setElementInterior ( col, interior )
		setElementDimension ( col, dimension )

		lookups.coliders[entryInterior] = col
		lookups.interiorFromColider[col] = entryInterior
		addEventHandler("onClientColShapeHit", col, colshapeHit) 

		---create return coliders
		local returnInterior = interiorTypeTable["return"]
		
		if getElementData(entryInterior, "oneway" ) ~= "true" then 
			entX, entY, entZ = tonumber(getElementData(returnInterior, "posX")), tonumber(getElementData(returnInterior, "posY")), tonumber(getElementData(returnInterior, "posZ"))
			dimension = tonumber(getElementData(returnInterior, "dimension")) or 0
			interior = tonumber(getElementData(returnInterior, "interior")) or 0

			col = createColSphere(entX, entY, entZ, 1.5)

			setElementParent(col, returnInterior)
			setElementInterior(col, interior)
			setElementDimension(col, dimension)

			lookups.interiorFromColider[col] = returnInterior
			lookups.coliders[returnInterior] = col
			addEventHandler("onClientColShapeHit", col, colshapeHit) 
		end
	end
end

function getInteriorMarker(elementInterior)
	if not isElement(elementInterior) then 
		outputDebugString("getInteriorName: Invalid variable specified as interior. Element expected, got " .. type(elementInterior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local interiorType = getElementType(elementInterior)
	if interiorType == "interiorEntry" or interiorType == "interiorReturn" then
		return interiorMarkers[elementInterior] or false
	end

	outputDebugString("getInteriorName: Bad element specified. Interior expected, got " .. interiorType .. ".", 0, unpack(outputColour))
	return false
end


function colshapeHit(player, matchingDimension)
	if (not isElement(player)) or getElementType(player) ~= "player" or player ~= localPlayer then 
		return 
	end

	if (not matchingDimension) or isPedInVehicle(player) or doesPedHaveJetPack(player) or (not isPedOnGround(player)) or getControlState("aim_weapon") or (not allowPlayerTeleporting) then 
		return 
	end

	local interior = lookups.interiorFromColider[source]
	local id = getElementData(interior, lookups.idDataName[getElementType(interior)]) 
	local resource = lookups.resources[interior]

	local eventNotCancelled = triggerEvent("onClientInteriorHit", interior)
	if eventNotCancelled then
		triggerServerEvent("doTriggerServerEvents", localPlayer, interior, getResourceName(resource), id)
	end
end

addEventHandler("doWarpPlayerToInterior", localPlayer,
	function(interior, resource, id)
		resource = getResourceFromName(resource)
		local oppositeType = lookups.opposite[getElementType(interior)]
		local targetInterior = interiors[resource][id][oppositeType]
		
		local x = tonumber(getElementData(targetInterior, "posX"))
		local y = tonumber(getElementData(targetInterior, "posY"))
		local z = tonumber(getElementData(targetInterior, "posZ")) + 1
		local dim = tonumber(getElementData(targetInterior, "dimension"))
		local int = tonumber(getElementData(targetInterior, "interior"))
		local rot = tonumber(getElementData(targetInterior, "rotation"))

		if (not x) or (not y) or (not z) or (not dim) or (not int) or (not rot) then
			outputDebugString(string.format("doWarpPlayerToInterior: Invalid warp data: %s %s %s %s %s %s", tostring(x), tostring(y), tostring(z), tostring(dim), tostring(int), tostring(rot)), 0, unpack(outputColour))
			return
		end

		toggleAllControls(false, true, false)
		fadeCamera(false, 1.0)
		setTimer(setPlayerInsideInterior, 1000, 1, source, int, dim, rot, x, y, z, interior)
		allowPlayerTeleporting = false

		setTimer(
			function() 
				allowPlayerTeleporting = true
			end, 
		3500, 1)
	end
)

function setPlayerInsideInterior(player, int, dim, rot, x, y, z, interior)
	setElementInterior(player, int)
	setCameraInterior(int)
	setElementDimension(player, dim)

	setPedRotation(player, rot % 360)
	setTimer(
		function(p) 
			if isElement(p) then 
				setCameraTarget(p) 
			end 
		end, 
	200, 1, player)

	setElementPosition(player, x, y, z)
	toggleAllControls(true, true, false)
	setTimer(fadeCamera, 500, 1, true, 1.0)

	triggerEvent("onClientInteriorWarped", interior)
	triggerServerEvent("onInteriorWarped", interior, player)
	triggerServerEvent("onPlayerInteriorWarped", player, interior)
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



