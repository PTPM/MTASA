local interiors = {}
local lookups = {
	markers = {},
	resources = {},

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

--[[format:
interior = { 
	[resource] = { 
		[id] = { 
			return = { [element],[element] }, 
			entry = [element] 
		} 
	}
}
]]

local resourceName = getResourceName(resource)
local settings = {
	immuneWhileTeleporting = get("immuneWhileTeleporting") == true,
	teleportImmunityLength = get("teleportImmunityLength") or 1000,

	name = 
		function(name, access)
			return access .. resourceName .. "." .. name
		end
}

addEventHandler("onSettingChange", root, 
	function(setting, oldValue, newValue)	
		--outputDebugString("Interior setting " .. setting .. " is " .. newValue)

		if setting == settings.name("immuneWhileTeleporting", "*") then
			settings.immuneWhileTeleporting = fromJSON(newValue)
			triggerClientEvent(root, "updateClientSettings", resourceRoot, settings)
		elseif setting == settings.name("teleportImmunityLength", "*") then
			settings.teleportImmunityLength = fromJSON(newValue)
			triggerClientEvent(root, "updateClientSettings", resourceRoot, settings)
		end
	end
)


addEvent("doTriggerServerEvents", true)
addEvent("onPlayerInteriorHit")
addEvent("onPlayerInteriorWarped", true)
addEvent("onInteriorHit")
addEvent("onInteriorWarped", true)
addEvent("onClientReady", true)
addEvent("onPlayerGroundLoaded", true)


addEventHandler("onResourceStart", root,
	function(resource)
		interiorLoadElements(getResourceRootElement(resource), resource)
		interiorCreateMarkers(resource)
	end
) 


addEventHandler("onResourceStop", root,
	function(resource)
		if not interiors[resource] then 
			return 
		end

		for id, interiorTable in pairs(interiors[resource]) do
			local entryMarker = lookups.markers[interiorTable["entry"]]
			local returnMarker = lookups.markers[interiorTable["return"]]

			if entryMarker then
				destroyElement(entryMarker)
			end

			if returnMarker then
				destroyElement(returnMarker)
			end
		end

		interiors[resource] = nil
	end 
)

addEventHandler("onClientReady", root,
	function()
		triggerClientEvent(client, "updateClientSettings", resourceRoot, settings)
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

function interiorCreateMarkers (resource)
	if not interiors[resource] then 
		return 
	end

	for interiorID, interiorTypeTable in pairs(interiors[resource]) do
		-- create entry marker
		local entryInterior = interiorTypeTable["entry"]
		local entX, entY, entZ = tonumber(getElementData(entryInterior, "posX")), tonumber(getElementData(entryInterior, "posY")), tonumber(getElementData(entryInterior, "posZ"))
		local dimension = tonumber(getElementData(entryInterior, "dimension")) or 0
		local interior = tonumber(getElementData(entryInterior, "interior")) or 0

		local marker = createMarker(entX, entY, entZ + 2.2, "arrow", 2, 255, 255, 0, 200)
		setElementParent(marker, entryInterior)	
		setElementInterior(marker, interior)
		setElementDimension (marker, dimension)

		lookups.markers[entryInterior] = marker


		---create return marker
		local returnInterior = interiorTypeTable["return"]

		if getElementData(entryInterior, "oneway") ~= "true" then 
			entX, entY, entZ = tonumber(getElementData(returnInterior, "posX")), tonumber(getElementData(returnInterior, "posY")), tonumber(getElementData(returnInterior, "posZ"))
	
			dimension = tonumber(getElementData(returnInterior, "dimension")) or 0
			interior = tonumber(getElementData ( returnInterior, "interior" )) or 0

			marker = createMarker(entX, entY, entZ + 2.2, "arrow", 2, 255, 255, 0, 200)
			setElementParent(marker, returnInterior)
			setElementInterior(marker, interior)
			setElementDimension(marker, dimension)

			lookups.markers[returnInterior] = marker
		end
	end
end


addEventHandler("doTriggerServerEvents", root,
	function(interior, resource, id)
		-- already teleporting somewhere
		if getElementData(client, "interiors.teleporting") then
			return
		end

		local playerEventNotCanceled = triggerEvent("onPlayerInteriorHit", client, interior, resource, id)
		local eventNotCanceled = triggerEvent("onInteriorHit", interior, client)

		if playerEventNotCanceled and eventNotCanceled then
			setElementData(client, "interiors.teleporting", true, false)

			if getElementData(client, "interiors.teleportImmunity") and isTimer(getElementData(client, "interiors.teleportImmunity")) then
				killTimer(getElementData(client, "interiors.teleportImmunity"))
				setElementData(client, "interiors.teleportImmunity", false, false)
			end

			setElementFrozen(client, true)
			toggleAllControls(client, false, true, false)
			fadeCamera(client, false, 1)

			setTimer(fadeIntoWarpComplete, 1000, 1, client, interior, resource, id)
		end
	end
)

function fadeIntoWarpComplete(player, interior, resource, id) 
	if not isElement(player) then
		return
	end

	local x, y, z = setPlayerInsideInterior(player, interior, resource, id)

	triggerClientEvent(player, "playerLoadingGround", player, interior, x, y, z)
end


function setPlayerInsideInterior(player, interior, resource, id)
	if not isElement(player) then
		return
	end

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

	setElementInterior(player, int)
	setCameraInterior(player, int)
	setElementDimension(player, dim)

	setElementRotation(player, 0, 0, rot % 360, "default", true)

	setTimer(
		function(p) 
			if isElement(p) then 
				setCameraTarget(p) 
			end 
		end, 
	200, 1, player)

	setElementPosition(player, x, y, z)

	return x, y, z
end

addEventHandler("onPlayerGroundLoaded", root,
	function(interior)
		if not getElementData(client, "interiors.teleporting") then
			return
		end

		setElementFrozen(client, false)
		toggleAllControls(client, true, true, false)	
		fadeCamera(client, true, 1)

		setElementData(client, "interiors.teleporting", false, false)

		triggerEvent("onInteriorWarped", interior, client)
 		triggerEvent("onPlayerInteriorWarped", client, interior)

 		local timer = setTimer(
 			function(p)
 				if isElement(p) then
 					setElementData(client, "interiors.teleportImmunity", false, false)
 				end
 			end,
 		settings.teleportImmunityLength, 1)

 		setElementData(client, "interiors.teleportImmunity", timer, false)
	end
)


function getInteriorMarker(elementInterior)
	if not isElement(elementInterior) then 
		outputDebugString("getInteriorMarker: Invalid variable specified as interior.  Element expected, got " .. type(elementInterior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local elemType = getElementType(elementInterior)
	if elemType == "interiorEntry" or elemType == "interiorReturn" then
		return lookups.markers[elementInterior] or false
	end

	outputDebugString("getInteriorMarker: Bad element specified.  Interior expected, got " .. elemType .. ".", 0, unpack(outputColour))
	return false
end


function getInteriorName(interior)
	if not isElement(interior) then 
		outputDebugString("getInteriorName: Invalid variable specified as interior.  Element expected, got " .. type(interior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local interiorType = getElementType(interior)

	if lookups.idDataName[interiorType] then
		return getElementData(interior, lookups.idDataName[interiorType])
	else
		outputDebugString("getInteriorName: Bad element specified.  Interior expected, got " .. interiorType .. ".", 0, unpack(outputColour))
		return false
	end
end

function getInteriorFromID(id, entry)
	for interiorID, interiorTypeTable in pairs(interiors[resource]) do
		if interiorID == id then
			return interiorTypeTable[entry and "entry" or "return"]
		end
	end

	return nil
end


addEventHandler("onPlayerStealthKill", root,
	function(target)
		if settings.immuneWhileTeleporting and (getElementData(target, "interiors.teleporting") or getElementData(target, "interiors.teleportImmunity")) then
			cancelEvent()
		end
	end
)


-- addCommandHandler("ti", 
-- 	function(player, command, i, count, r) 
-- 		local id = i

-- 		-- bodge to allow for the ids with spaces in the format "name (number)"
-- 		if count and tonumber(count) and tonumber(count) > 0 then
-- 			id = id .. " (" .. tostring(count) .. ")"
-- 		end

-- 		local interior = getInteriorFromID(id, r == nil)

-- 		if interior == nil then
-- 			outputChatBox("Could not find marker " .. i)
-- 			return
-- 		end

-- 		local entX, entY, entZ = getElementData(interior, "posX"), getElementData(interior, "posY"), getElementData(interior, "posZ")
-- 		local int = getElementData(interior, "interior")
-- 		local dim = getElementData(interior, "dimension")

-- 		setElementPosition(player, entX, entY, entZ + 0.5)
-- 		setElementInterior(player, int)
-- 		setElementDimension(player, dim)
-- 	end
-- )

-- addCommandHandler("nearestt", 
-- 	function(player)
-- 		local x, y, z = getElementPosition(player)
-- 		local closestDistance = 9999
-- 		local closestID = ""
-- 		local closestType = ""

-- 		for interiorID, interiorTypeTable in pairs(interiors[resource]) do
-- 			local interior = interiorTypeTable["entry"]
-- 			local tX, tY, tZ = tonumber(getElementData(interior, "posX")), tonumber(getElementData(interior, "posY")), tonumber(getElementData(interior, "posZ"))

-- 			local d = getDistanceBetweenPoints3D(x, y, z, tX, tY, tZ)

-- 			if d < closestDistance then
-- 				closestDistance = d
-- 				closestID = interiorID
-- 				closestType = "entry"
-- 			end

-- 			interior = interiorTypeTable["return"]
-- 			tX, tY, tZ = tonumber(getElementData(interior, "posX")), tonumber(getElementData(interior, "posY")), tonumber(getElementData(interior, "posZ"))

-- 			d = getDistanceBetweenPoints3D(x, y, z, tX, tY, tZ)

-- 			if d < closestDistance then
-- 				closestDistance = d
-- 				closestID = interiorID
-- 				closestType = "return"
-- 			end			
-- 		end

-- 		if #closestID == 0 then
-- 			outputDebugString("Could not find any teleport points")
-- 			return
-- 		end

-- 		local _,_,rz = getElementRotation(player)

-- 		outputChatBox("Closest teleport: " .. closestType .. " " .. closestID .. " (rot: " .. rz .. ")")
-- 	end
-- )