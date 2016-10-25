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
	name = 
		function(name, access)
			return access .. resourceName .. "." .. name
		end
}

addEventHandler("onSettingChange", root, 
	function(setting, oldValue, newValue)	
		--outputDebugString("Interior setting " .. setting .. " is " .. newValue)
	end
)


addEvent("doTriggerServerEvents", true)
addEvent("onPlayerInteriorHit")
addEvent("onPlayerInteriorWarped", true)
addEvent("onInteriorHit")
addEvent("onInteriorWarped", true)
addEvent("onClientReady", true)


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
			local interior1 = interiorTable["entry"]
			local interior2 = interiorTable["return"]
			destroyElement(lookups.markers[interior1])
			destroyElement(lookups.markers[interior2])
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

function getInteriorMarker(elementInterior)
	if not isElement(elementInterior) then 
		outputDebugString("getInteriorName: Invalid variable specified as interior.  Element expected, got " .. type(elementInterior) .. ".", 0, unpack(outputColour)) 
		return false 
	end

	local elemType = getElementType(elementInterior)
	if elemType == "interiorEntry" or elemType == "interiorReturn" then
		return lookups.markers[elementInterior] or false
	end

	outputDebugString("getInteriorName: Bad element specified.  Interior expected, got " .. elemType .. ".", 0, unpack(outputColour))
	return false
end



addEventHandler("doTriggerServerEvents", root,
	function(interior, resource, id)
		local playerEventNotCanceled = triggerEvent("onPlayerInteriorHit", client, interior, resource, id)
		local eventNotCanceled = triggerEvent("onInteriorHit", interior, client)

		if playerEventNotCanceled and eventNotCanceled then
			triggerClientEvent(client, "doWarpPlayerToInterior", client, interior, resource, id)
			setTimer(setPlayerInsideInterior, 1000, 1, client, interior, resource, id)
		end
	end
)


function setPlayerInsideInterior(player, interior, resource, id)
	if not isElement(player) then
		return
	end

	local oppositeType = lookups.opposite[getElementType(interior)]
	local targetInterior = interiors[getResourceFromName(resource) or getThisResource()][id][oppositeType]
	local dim = tonumber(getElementData(targetInterior, "dimension")) or 0
	local int = tonumber(getElementData(targetInterior, "interior")) or 0

	setElementInterior(player, int)
	setElementDimension(player, dim)
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




addCommandHandler("ti", function(player, command, i) 
	local interior

	for interiorID, interiorTypeTable in pairs(interiors[resource]) do
		if interiorID == i then
			interior = interiorTypeTable
		end
	end
	
	if interior == nil then
		return
	end

	local entryInterior = interior["entry"]
	local entX,entY,entZ = getElementData ( entryInterior, "posX" ),getElementData ( entryInterior, "posY" ),getElementData ( entryInterior, "posZ" )
	outputDebugString(entryInterior)
	setElementPosition(player, entX, entY, entZ)
end
)

